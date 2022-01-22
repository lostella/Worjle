using Worjle
using Test

@testset "compute_feedback" begin
    
    @test Worjle.compute_feedback("sissy", "reals") == "bbbby"
    @test Worjle.compute_feedback("sissy", "spots") == "gbbby"
    @test Worjle.compute_feedback("proxy", "proof") == "gggbb"
    @test Worjle.compute_feedback("proof", "proxy") == "gggbb"

end
