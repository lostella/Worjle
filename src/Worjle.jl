module Worjle

using ProgressMeter

const feedback_atoms = ['b', 'y', 'g']

function validate_feedback(feedback)
    feedback == "!" && return true
    length(feedback) == 5 && all(in.(collect(feedback), Ref(feedback_atoms))) && return true
    @warn "feedback should of length 5, with characters from $feedback_atoms; got \"$feedback\""
    return false
end

function read_feedback(guess)
    println("  $guess")
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
    return string(feedback_vector...)
end

function find_best_guess(words)
    best_guess = words[1]
    best_score = typemax(Int)
    @showprogress for guess in words
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
    end
    return best_guess
end

default_word_list() = collect(eachline(joinpath(@__DIR__, "data", "words.txt")))

function play(feedback_fn::Function=read_feedback, words::Vector{String}=default_word_list(), max_guesses=10)
    num_guesses = 0
    while num_guesses < max_guesses
        guess = num_guesses == 0 && "serai" in words ? "serai" : find_best_guess(words)
        feedback = feedback_fn(guess)
        if feedback == "!"
            deleteat!(words, findall(isequal(guess), words))
            continue
        end
        num_guesses += 1
        feedback == "ggggg" && break
        words = filter(w -> compute_feedback(w, guess) == feedback, words)
        if length(words) == 0
            @error "I'm sorry, I'm out of words :-("
            num_guesses = max_guesses
        end
    end
    return num_guesses
end

play(word::String, args...) = play(guess -> compute_feedback(word, guess), args...)

play(n::Int, words::Vector{String}=default_word_list(), args...) = @showprogress [play(rand(words), args...) for _ in 1:n]

end # module
