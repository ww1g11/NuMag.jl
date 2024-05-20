using NuMag
using Test
using LinearAlgebra

function test_anis()
    mesh = FDMesh(; nx=10, ny=1, nz=1)

    sim = Sim(mesh)
    Ms = 8.6e5
    set_Ms(sim, Ms)

    m = (1.1, 2.3, 4.3)
    init_m0(sim, m; norm=false)

    Ku = 1e5
    axis = (0, 0.6, 0.8)
    anis = add_anis(sim, Ku; axis=axis)

    NuMag.effective_field(sim, sim.spin, 0.0)

    field = Array(anis.field)
    energy = Array(anis.energy)

    @test isapprox(field[1], 0)
    @test isapprox(field[2], 2 * Ku / (NuMag.mu_0 * Ms) * dot(m, axis) * axis[2])
    @test isapprox(field[3], 2 * Ku / (NuMag.mu_0 * Ms) * dot(m, axis) * axis[3])
    @test isapprox(energy[10], Ku * (1 - dot(m, axis)^2) * 1e-27)
end

function test_cubic_anis()
    mesh = FDMesh(; nx=10, ny=1, nz=1)

    sim = Sim(mesh)
    Ms = 8.6e5
    Kc = 1e3
    set_Ms(sim, Ms)
    init_m0(sim, (0.6, 0.8, 0); norm=false)

    anis = add_cubic_anis(sim, Kc)

    NuMag.effective_field(sim, sim.spin, 0.0)

    field = Array(anis.field)
    energy = Array(anis.energy)

    @test isapprox(field[1], 1 / (NuMag.mu_0 * Ms) * 4 * Kc * 0.6^3)
    @test isapprox(field[2], 1 / (NuMag.mu_0 * Ms) * 4 * Kc * 0.8^3)
    @test isapprox(field[3], 1 / (NuMag.mu_0 * Ms) * 4 * Kc * 0^3)
    @test isapprox(energy[1], -Kc * (0.6^4 + 0.8^4) * 1e-27)
end

@testset "Test Anisotropy CPU" begin
    set_backend("cpu")
    test_anis()
    test_cubic_anis()
end

@testset "Test Anisotropy CUDA" begin
    if Base.find_package("CUDA") !== nothing
        using CUDA
        test_anis()
        test_cubic_anis()
    end
end
