using Ratios, Test

@testset "SimpleRatio" begin
    r = SimpleRatio(1,2)
    @test convert(Float64, r) == 0.5
    @test convert(Float32, r) == 0.5f0
    @test convert(BigFloat, r) == BigFloat(1)/2

    r2 = SimpleRatio(2,3)
    @test r*r2 == SimpleRatio(2,6) == SimpleRatio(1,3)
    @test r2*3 == 3*r2 == 2
    @test r*false == false*r == 0
    @test r/r2 == SimpleRatio(3,4)
    @test r/2 == SimpleRatio(1,4)
    @test 2/r == 4
    @test 4 == 2/r
    @test r+1 == 1+r == SimpleRatio(3,2)
    @test r-1 == SimpleRatio(-1,2)
    @test 1-r == r
    @test r+r2 == SimpleRatio(7,6)
    @test r-r2 == SimpleRatio(-1,6)
    @test r^2 == SimpleRatio(1,4)
    @test -r == SimpleRatio(-1,2)
    @test 0.2*r ≈ 0.1
    @test r == 0.5
    @test 0.5 == r

    @test_throws OverflowError -SimpleRatio(0x02,0x03)

    @test r + SimpleRatio(0x02,0x03) == SimpleRatio(7,6)

    @test SimpleRatio(11, 10) == 11//10
    @test 1//3 + SimpleRatio(1, 5) == 8//15

    @test isfinite(SimpleRatio(0,0)) == false
    @test isfinite(SimpleRatio(1,0)) == false
    @test isfinite(SimpleRatio(2,1)) == true
end
