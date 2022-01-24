module Worjle

using ProgressMeter

default_word_list() = collect(eachline(joinpath(@__DIR__, "data", "large.txt")))

wordle_target() = collect(eachline(joinpath(@__DIR__, "data", "wordle_target.txt")))

wordle_all() = vcat(
    collect(eachline(joinpath(@__DIR__, "data", "wordle_target.txt"))),
    collect(eachline(joinpath(@__DIR__, "data", "wordle_additional.txt"))),
)

const feedback_chars = ['b', 'y', 'g']

function validate_feedback(feedback)
    feedback == "!" && return true
    length(feedback) == 5 && all(in.(collect(feedback), Ref(feedback_chars))) && return true
    @warn "feedback should of length 5, with characters from $feedback_chars; got \"$feedback\""
    return false
end

function read_feedback(guess)
    printstyled("          $guess\n"; bold=true)
    while true
        print("feedback> ")
        feedback = readline() |> strip
        feedback = isempty(feedback) ? "ggggg" : feedback
        validate_feedback(feedback) && return feedback
    end
end

function validate_guess(guess)
    length(guess) == 5 && return true
    @warn "guess should of length 5; got \"$guess\""
    return false
end

function read_guess(feedback)
    if feedback !== nothing
        printstyled("          $feedback\n"; bold=true)
    end
    while true
        print("   guess> ")
        guess = readline() |> strip
        validate_guess(guess) && return guess
    end
end

function compute_feedback(target, guess)
    target_vector = collect(target)
    feedback_vector = ['b', 'b', 'b', 'b', 'b']
    for k in 1:length(target_vector)
        if guess[k] == target_vector[k]
            feedback_vector[k] = 'g'
            target_vector[k] = '.'
        end
    end
    for k in 1:length(target_vector)
        feedback_vector[k] == 'g' && continue
        j = findfirst(isequal(guess[k]), target_vector)
        j === nothing && continue
        feedback_vector[k] = 'y'
        target_vector[j] = '.'
    end
    return join(feedback_vector)
end

function min_max_guess(guesses, targets; verbose::Bool=true)
    if verbose
        @info "$(length(targets)) words in the list"
    end
    length(targets) == 1 && return targets[1]
    best_guess = guesses[1]
    best_score = typemax(Int)
    p = Progress(length(guesses); enabled=verbose)
    for guess in guesses
        count = Dict{String, Int}()
        for target in targets
            feedback = compute_feedback(target, guess)
            if !(feedback in keys(count))
                count[feedback] = 0
            end
            count[feedback] += 1
            if count[feedback] >= best_score
                break
            end
        end
        score = maximum(values(count))
        if score < best_score
            best_score = score
            best_guess = guess
        end
        ProgressMeter.next!(p; showvalues=[(:guess, best_guess), (:score, best_score)])
    end
    return best_guess
end

struct InteractiveGuess end

function make_guess(::InteractiveGuess, state=nothing, feedback=nothing)
    guess = read_guess(feedback)
    return state, guess
end

Base.@kwdef struct MinMaxGuess
    words::Vector{String}=default_word_list()
    first_guess::String="serai"
    hard_mode::Bool=true
end

function make_guess(guesser::MinMaxGuess, state=nothing, previous_guess_feedback=nothing; verbose::Bool=true)
    @assert (state === nothing) == (previous_guess_feedback === nothing)
    words, candidates = state === nothing ? (guesser.words, guesser.words) : state
    if previous_guess_feedback !== nothing
        previous_guess, feedback = previous_guess_feedback
        if feedback == "!"
            deleteat!(words, findall(isequal(previous_guess), words))
            deleteat!(candidates, findall(isequal(previous_guess), candidates))
        else
            candidates = filter(w -> compute_feedback(w, previous_guess) == feedback, candidates)
            words = guesser.hard_mode ? candidates : words
        end
    end
    guess = if length(words) == 0
        @error "I'm sorry, I'm out of words :-("
        nothing
    elseif previous_guess_feedback === nothing
        guesser.first_guess
    else
        min_max_guess(words, candidates; verbose)
    end
    return (words, candidates), guess
end

struct Quiet{T}
    guesser::T
end

make_guess(q::Quiet, args...) = make_guess(q.guesser, args...; verbose=false)

struct InteractiveFeedback end

give_feedback(::InteractiveFeedback, guess) = read_feedback(guess)

struct WordFeedback
    target::String
end

give_feedback(wf::WordFeedback, guess) = compute_feedback(wf.target, guess)

function play(feedback_giver=InteractiveFeedback(), guesser=MinMaxGuess(default_word_list(), "serai", true))
    state, guess = make_guess(guesser)
    feedback = give_feedback(feedback_giver, guess)
    history = Pair{String, String}[guess=>feedback]
    while feedback != "ggggg"
        state, guess = make_guess(guesser, state, guess=>feedback)
        guess === nothing && break
        feedback = give_feedback(feedback_giver, guess)
        push!(history, guess=>feedback)
    end
    return history
end

play(target::String, args...) = play(WordFeedback(target), args...)

play(targets::Vector{String}, args...) = @showprogress [play(target, args...) for target in targets]

end # module
