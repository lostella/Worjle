using Worjle
using Test

@testset "compute_feedback" begin
    
    @test Worjle.compute_feedback("sissy", "reals") == "bbbby"
    @test Worjle.compute_feedback("sissy", "spots") == "gbbby"
    @test Worjle.compute_feedback("proxy", "proof") == "gggbb"
    @test Worjle.compute_feedback("proof", "proxy") == "gggbb"

end

@testset "play" begin

    @test Worjle.play("silly") <= 4
    @test Worjle.play("prick") <= 4
    @test Worjle.play("bombs") <= 6
    @test Worjle.play("after") <= 3
    @test Worjle.play("robot") <= 4
    @test Worjle.play("night") <= 3

end