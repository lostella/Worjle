using Worjle: compute_feedback, find_best_guess, quiet, play, wordle_target
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

    @inferred quiet(find_best_guess)(words, words)

    words = wordle_target()

    @test quiet(find_best_guess)(words, words) in ["arise", "serai"]

end

@testset "play" begin

    words_num_guesses = [("silly", 4), ("prick", 4), ("bombs", 6), ("after", 3), ("robot", 4), ("night", 3)]

    for (word, num_guesses) in words_num_guesses
        history = play(word; player_fn=quiet(find_best_guess), hard_mode=true)
        @test length(history) <= num_guesses
        @test history[end][2] == "ggggg"
    end

end
