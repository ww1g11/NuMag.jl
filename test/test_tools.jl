using JuMag
using Test
using Printf

function savem()
    sim = Sim(nx=32,ny=64,nz=16,Ms=1e5,GPU=false)
    init_m0(sim,(cos(5/3*pi),sin(5/3*pi),0))
    save_ovf(sim,"test_tools")
end

savem()
OVF2XRAY("test_tools")
OVF2MFM("test_tools")
plotOVF("test_tools")


#TODO:phase test
#=function F0(x::Float64, y::Float64)
    eps = 1e-10
    if abs(x)<eps && abs(y)<eps
        return 0
    end
    return x*log(x^2+y^2) - 2*x + 2*y*atan(x/y)
end

function phim_uniformly_magnetized_slab(x, y, mx, my, Lx, Ly, Lz, Ms)
    mu0 = 4*pi*1e-7
    Phi0 = 2.067833e-15
    a = F0(x-Lx/2, y-Ly/2) - F0(x+Lx/2, y-Ly/2) - F0(x-Lx/2, y+Ly/2) + F0(x+Lx/2, y+Ly/2)
    b = F0(y-Ly/2, x-Lx/2) - F0(y+Ly/2, x-Lx/2) - F0(y-Ly/2, x+Lx/2) + F0(y+Ly/2, x+Lx/2)
    #println(a, " ", b, "  ", my*b-mx*a)
    return mu0*Ms*Lz/(4*Phi0)*(my*b-mx*a)*1e-18
end

function phase_theory()
    mx = cos(5/3*pi)
    my = sin(5/3*pi)
    Lx = 32
    Ly = 64
    Lz = 16
    Nx, Ny = 160, 160
    Ms = 1e5
    phi = zeros(Nx, Nx)
    for i = 1:Nx, j=1:Ny
        x = (i/Nx-0.5)*160
        y = (j/Ny-0.5)*160
        phi[i, j] = phim_uniformly_magnetized_slab(x, y, mx, my, Lx, Ly, Lz, Ms)
    end
    
    return phi
end

theory = phase_theory()
phase,intensity = OVF2LTEM("test_tools",Nx=160,Ny=160)

#@test isapprox(theory[])
@info("test tools passed!")=#