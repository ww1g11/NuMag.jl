#implement the classical Runge-Kutta method for testing purpose

mutable struct RungeKutta <: Integrator
   t::Float64
   step::Float64
   nsteps::Int64
   k1::Array{Float64, 1}
   k2::Array{Float64, 1}
   k3::Array{Float64, 1}
   k4::Array{Float64, 1}
   rhs_fun::Function
end

function RungeKutta(n_nodes::Int64, rhs_fun, step::Float64)
  k1 = zeros(Float64,3*n_nodes)
  k2 = zeros(Float64,3*n_nodes)
  k3 = zeros(Float64,3*n_nodes)
  k4 = zeros(Float64,3*n_nodes)
  return RungeKutta(0.0, step, 0, k1, k2, k3, k4, rhs_fun)
end

function advance_step(sim::AbstractSim, integrator::RungeKutta)
    h = integrator.step
	k1 =  integrator.k1
	k2 =  integrator.k2
	k3 =  integrator.k3
	k4 =  integrator.k4

	#compute k1
    integrator.rhs_fun(sim, k1, sim.spin, integrator.t)

    #compute k2
	sim.prespin .= sim.spin .+ 0.5 .*h.*k1
	integrator.rhs_fun(sim, k2, sim.prespin, integrator.t+0.5*h)

    #compute k3
	sim.prespin .= sim.spin .+ 0.5 .*h.*k2
	integrator.rhs_fun(sim, k3, sim.prespin, integrator.t+0.5*h)

    #compute k4
	sim.prespin .= sim.spin .+ h.*k3
	integrator.rhs_fun(sim, k4, sim.prespin, integrator.t+h)

    sim.prespin .= sim.spin
    sim.spin .+= (1.0/6*h).*(k1 .+ 2 .*k2 + 2 .*k3 .+ k4)

    normalise(sim.spin, sim.n_nodes)
    integrator.nsteps += 1
    integrator.t = integrator.nsteps*h
end
