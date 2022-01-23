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

function find_best_guess(words; show_progress::Bool=true)
    best_guess = words[1]
    best_score = typemax(Int)
    p = Progress(length(words); enabled=show_progress)
    for guess in words
        count = Dict{String, Int}()
        for word in words
            feedback = compute_feedback(word, guess)
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

default_word_list() = collect(eachline(joinpath(@__DIR__, "data", "large.txt")))
wordle_target_list() = collect(eachline(joinpath(@__DIR__, "data", "wordle_target.txt")))

function play(
    feedback_fn::Function=read_feedback;
    words::Vector{String}=default_word_list(),
    first_guess::Union{Nothing, String}="serai",
    max_guesses::Int=typemax(Int),
    show_progress::Bool=true,
)
    history = Pair{String, String}[]
    while length(history) < max_guesses
        guess = length(history) == 0 && first_guess in words ? first_guess : find_best_guess(words; show_progress)
        feedback = feedback_fn(guess)
        if feedback == "!"
            deleteat!(words, findall(isequal(guess), words))
            continue
        end
        push!(history, guess=>feedback)
        feedback == "ggggg" && break
        words = filter(w -> compute_feedback(w, guess) == feedback, words)
        if length(words) == 0
            @error "I'm sorry, I'm out of words :-("
            break
        end
    end
    return history
end

play(word::String; kwargs...) = play(guess -> compute_feedback(word, guess); kwargs...)

function play(n::Int; words::Vector{String}=default_word_list(), kwargs...)
    first_guess = find_best_guess(words)
    @showprogress [play(rand(words); words, first_guess, show_progress=false, kwargs...) for _ in 1:n]
end

end # module
