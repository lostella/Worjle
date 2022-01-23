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

    @inferred Worjle.find_best_guess(["sissy", "reals", "spots", "proxy", "proof", "bobby", "table", "phase"])

    @test Worjle.find_best_guess(Worjle.wordle_target_list(); show_progress=false) in ["arise", "serai"]

end

@testset "play" begin

    @test Worjle.play("silly"; show_progress=false) <= 4
    @test Worjle.play("prick"; show_progress=false) <= 4
    @test Worjle.play("prick"; show_progress=false) <= 6
    @test Worjle.play("after"; show_progress=false) <= 3
    @test Worjle.play("robot"; show_progress=false) <= 4
    @test Worjle.play("night"; show_progress=false) <= 3

end
