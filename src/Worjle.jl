module Worjle

using ProgressMeter

const feedback_chars = ['b', 'y', 'g']

function validate_feedback(feedback)
    feedback == "!" && return true
    length(feedback) == 5 && all(in.(collect(feedback), Ref(feedback_chars))) && return true
    @warn "feedback should of length 5, with characters from $feedback_chars; got \"$feedback\""
    return false
end

function read_feedback(guess)
    printstyled("  $guess\n"; bold=true)
    while true
        print("> ")
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
    printstyled("  $feedback\n"; bold=true)
    while true
        print("> ")
        guess = readline() |> strip
        validate_guess(guess) && return guess
    end
end

function compute_feedback(word, guess)
    word_vector = collect(word)
    feedback_vector = ['b', 'b', 'b', 'b', 'b']
    for k in 1:length(word_vector)
        if guess[k] == word_vector[k]
            feedback_vector[k] = 'g'
            word_vector[k] = '.'
        end
    end
    for k in 1:length(word_vector)
        feedback_vector[k] == 'g' && continue
        j = findfirst(isequal(guess[k]), word_vector)
        j === nothing && continue
        feedback_vector[k] = 'y'
        word_vector[j] = '.'
    end
    return join(feedback_vector)
end

function find_best_guess(guesses, targets; show_progress::Bool=true)
    length(targets) == 1 && return targets[1]
    best_guess = guesses[1]
    best_score = typemax(Int)
    p = Progress(length(guesses); enabled=show_progress)
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

find_best_guess_quiet(guesses, targets) = find_best_guess(guesses, targets; show_progress=false)

default_word_list() = collect(eachline(joinpath(@__DIR__, "data", "large.txt")))

wordle_target() = collect(eachline(joinpath(@__DIR__, "data", "wordle_target.txt")))

wordle_all() = vcat(
    collect(eachline(joinpath(@__DIR__, "data", "wordle_target.txt"))),
    collect(eachline(joinpath(@__DIR__, "data", "wordle_additional.txt"))),
)

function play(
    feedback_fn::Function=read_feedback;
    player_fn::Function=find_best_guess,
    words::Vector{String}=default_word_list(),
    hard_mode::Bool=true,
    first_guess::Union{Nothing, String}="serai",
    max_guesses::Int=typemax(Int),
)
    guesses = words
    history = Pair{String, String}[]
    while length(history) < max_guesses
        guess = length(history) == 0 && first_guess in guesses ? first_guess : player_fn(guesses, words)
        feedback = feedback_fn(guess)
        if feedback == "!"
            deleteat!(words, findall(isequal(guess), words))
            deleteat!(guesses, findall(isequal(guess), guesses))
            continue
        end
        push!(history, guess=>feedback)
        feedback == "ggggg" && break
        words = filter(w -> compute_feedback(w, guess) == feedback, words)
        guesses = hard_mode ? words : guesses
        if length(guesses) == 0
            @error "I'm sorry, I'm out of words :-("
            break
        end
    end
    return history
end

play(target::String; kwargs...) = play(guess -> compute_feedback(target, guess); kwargs...)

function play(targets::Vector{String}; player_fn=find_best_guess_quiet, words::Vector{String}=default_word_list(), kwargs...)
    first_guess = find_best_guess(words, words)
    @showprogress [play(target; player_fn, words, first_guess, kwargs...) for target in targets]
end

end # module
