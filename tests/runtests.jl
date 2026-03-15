using Test

module MathTheoryLabTests
include("../math_theory_lab.jl")
end

module ProbabilityStudioTests
include("../probability_studio.jl")
end

module TrigonometryStudioTests
include("../trigonometry_studio.jl")
end

@testset "Math Theory Core Formulas" begin
    @test MathTheoryLabTests.modpow_big(BigInt(2), BigInt(10), BigInt(1000)) == BigInt(24)
    @test MathTheoryLabTests.fibonacci_fast(BigInt(10)) == BigInt(55)
    @test MathTheoryLabTests.binomial_big(BigInt(5), BigInt(2)) == BigInt(10)
    @test MathTheoryLabTests.catalan_big(BigInt(5)) == BigInt(42)
    @test MathTheoryLabTests.partition_number(5) == BigInt(7)

    @test MathTheoryLabTests.miller_rabin_64(BigInt(17)) == true
    @test MathTheoryLabTests.miller_rabin_64(BigInt(21)) == false

    x, m = MathTheoryLabTests.chinese_remainder(BigInt[2, 3, 2], BigInt[3, 5, 7])
    @test x == BigInt(23)
    @test m == BigInt(105)

    bs = MathTheoryLabTests.black_scholes_call(120.0, 100.0, 0.04, 0.3, 1.5)
    @test isapprox(bs, 31.741493, atol=1e-6)

    z = MathTheoryLabTests.zeta_eta(2.0, 200_000)
    @test isapprox(z, (pi^2) / 6, atol=1e-5)

    r = MathTheoryLabTests.newton_cuberoot(27.0, 1.0, 20)
    @test isapprox(r, 3.0, atol=1e-10)

    @test MathTheoryLabTests.euler_totient_big(BigInt(36)) == BigInt(12)

    ll, _ = MathTheoryLabTests.lucas_lehmer_test(5)
    @test ll == true

    px, py, _ = MathTheoryLabTests.pell_fundamental_solution(2)
    @test px == BigInt(3)
    @test py == BigInt(2)

    _, _, err = MathTheoryLabTests.stirling_ln_factorial_error(1000)
    @test err > 0
end

@testset "Probability Core Formulas" begin
    @test isapprox(ProbabilityStudioTests.binomial_pmf(10, 3, 0.5), 0.1171875, atol=1e-12)
    @test isapprox(ProbabilityStudioTests.poisson_pmf(3.0, 2), 0.22404180765538775, atol=1e-12)
end

@testset "Trigonometry Core Formulas" begin
    @test isapprox(TrigonometryStudioTests.to_radians(180.0, :deg), pi, atol=1e-12)
    @test isapprox(TrigonometryStudioTests.to_unit(Float64(pi), :deg), 180.0, atol=1e-12)
    @test isapprox(TrigonometryStudioTests.safe_cot(pi / 4), 1.0, atol=1e-12)

    lhs = sin(TrigonometryStudioTests.to_radians(1234.5, :deg))^2 + cos(TrigonometryStudioTests.to_radians(1234.5, :deg))^2
    @test isapprox(lhs, 1.0, atol=1e-12)
end
