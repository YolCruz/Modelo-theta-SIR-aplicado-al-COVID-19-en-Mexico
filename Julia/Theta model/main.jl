include("ThetaModel.jl")
using Plots
using BSON: @save, @load
#using CUDA, Evolutionary



saved = Dict(
    "t0" => 0,
    "tMAX" => 446,
    "t_iCFR" => 23,
    "t_θ0" => 29,
    "t_n" => 13,
    "γ_d" => 1/13.123753454738198,
    #"γ_E" => 1/5.5,
    #"γ_I" => 1/5,
    #"γ_IDu" => 0,
    "m0" => 1,
    "m1" => 1,
    "m4" => 0,
    "ω" => 0.014555,
    "ω_0" =>0.50655
)

lambdas = [
    "2020-03-20",
    "2020-03-23",
    "2020-03-30",
    "2020-04-21",
    "2020-06-01"
]



const N = 127575528.0

#st_pr = StaticParams(opt, saved)

path = "D:\\Code\\[Servicio Social]\\Datos\\Casos_Modelo_Theta_final.csv"
data = Data(path)
dates = day_to_index(lambdas, data)


#u0 = [1.0; N; 0.0;0.0;0.0;0.0;0.0;0.0;0.0;0.0;0.0;0.0]


# opt = Dict(
#     "γ_Iu" => 0.5,
#     "γ_E" => 0.5,
#     "γ_I" => 0.9323648875748609,
#     "γ_IDu" => 1.0,
#     "γ_Q" => 0.5,
#     "γ_Hr" => 1.0e-6,
#     "γ_Hd" => 1.0,
#     "β_I0" => 0.5,
#     "c_E" => 1.0e-6,
#     "c_u" => 1.0e-6,
#     "c_IDu" => 0.5,
#     "ρ0" => 1.0e-6,
#     "ks" => [0.5],
#     "cs" => [0.6417949354396546, 0.5],
#     "ω_u0" => 0.5676556045969086 #
# )

opt = Dict{String, Any}("cs" => [0.6417949354396546, 1.0], "γ_Hr" => 1.0e-6, "γ_I" => 0.9323648875748609, "ρ0" => 1.0e-6, "γ_IDu" => 1.0, "ω_u0" => 0.5676556045969086, "c_u" 
=> 1.0e-6, "c_E" => 1.0e-6, "γ_Hd" => 1.0, "ks" => [0.878536887580943], "γ_E" => 1.0, "γ_Iu" => 1.0e-6, "γ_Q" => 1.0e-6, "c_IDu" => 0.5212477789281397, "β_I0" => 1.0)

# t=1.0
# u0 = [1.0, N-1, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
# tspan = (1.0, 446.0)

gam_val = γs(opt, saved)
st_val = StaticParams(opt, saved, data, gam_val)
ms_val = Msλs(opt, saved, dates)
tt = TimeParams(4, opt, saved, data, st_val, ms_val, gam_val)
tt.η
# be = βs(2, opt, saved, tt, ms_val, gam_val)

#solution = sol(ode!, u0, tspan, [TimeParams, βs])
isinf(1/0)

ga = GA(populationSize=100,selection=uniformranking(3),
        mutation=gaussian(),crossover=uniformbin())

num_params = 16
low = fill(0.001,num_params)
up = fill(1.0, num_params)
x0 = fill(0.5, num_params)

minim_params = minim(x0, low, up, ga)

@save "model_minimum.bson" minim_params

minim_found = Evolutionary.minimizer(minim_params)
minim_found = Dict(
    "γ_Iu" => 0.2218361076416862,
    "γ_Q" => 1.0,
    "γ_Hr" => 0.8986061877668314,
    "γ_Hd" => 1.0,
    "β_I0" => 1.0,
    "c_E" => 1.0,
    "c_u" => 0.0,
    "c_IDu" => 0.0,
    "ρ0" => 0.0,
    "ks" => [1.0],
    "cs" => [0.0, 1.0],
    "ω_u0" => 1.0 #
)

Evolutionary.minimum(minim_params)

solution = sol(ode!, u0, tspan, [full_params,minim_found])

plot(solution, vars=(0,1))
plot(solution, vars=(0,2))
plot(solution, vars=(0,3))
plot(data.infec)
plot(solution, vars=(0,4))
plot(solution, vars=(0,5))
plot(solution, vars=(0,6))
plot(solution, vars=(0,7))