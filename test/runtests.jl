using Worjle: default_word_list, wordle_target, compute_feedback, min_max_guess, MinMaxGuess, Quiet, play
using Test

@testset "compute_feedback" begin
    
    @inferred compute_feedback("sissy", "reals")

    @test compute_feedback("sissy", "reals") == "bbbby"
    @test compute_feedback("sissy", "spots") == "gbbby"
    @test compute_feedback("spots", "sissy") == "gbybb"
    @test compute_feedback("story", "spots") == "gbgyb"
    @test compute_feedback("proxy", "proof") == "gggbb"
    @test compute_feedback("proof", "proxy") == "gggbb"

end

@testset "find_best_guess" begin

    words = ["sissy", "reals", "spots", "proxy", "proof", "bobby", "table", "phase"]

    @inferred min_max_guess(words, words; verbose=false)

    words = wordle_target()

    @test min_max_guess(words, words; verbose=false) in ["arise", "serai"]

end

@testset "play" begin

    words_num_guesses = [("silly", 4), ("prick", 4), ("bombs", 6), ("after", 3), ("robot", 4), ("night", 3)]

    for (word, num_guesses) in words_num_guesses
        history = play(word, Quiet(MinMaxGuess(default_word_list(), "serai", true)))
        @test length(history) <= num_guesses
        @test history[end][2] == "ggggg"
    end

end
