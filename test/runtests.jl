using Worjle
using Test

@testset "compute_feedback" begin
    
    @inferred Worjle.compute_feedback("sissy", "reals")

    @test Worjle.compute_feedback("sissy", "reals") == "bbbby"
    @test Worjle.compute_feedback("sissy", "spots") == "gbbby"
    @test Worjle.compute_feedback("proxy", "proof") == "gggbb"
    @test Worjle.compute_feedback("proof", "proxy") == "gggbb"

end

@testset "find_best_guess" begin

    words = ["sissy", "reals", "spots", "proxy", "proof", "bobby", "table", "phase"]

    @inferred Worjle.find_best_guess(words, words; show_progress=false)

    words = Worjle.wordle_target()

    @test Worjle.find_best_guess(words, words; show_progress=false) in ["arise", "serai"]

end

@testset "play" begin

    words_num_guesses = [("silly", 4), ("prick", 4), ("bombs", 6), ("after", 3), ("robot", 4), ("night", 3)]

    for (word, num_guesses) in words_num_guesses
        history = Worjle.play(word; player_fn=Worjle.find_best_guess_quiet, hard_mode=true)
        @test length(history) <= num_guesses
        @test history[end][2] == "ggggg"
    end

end
