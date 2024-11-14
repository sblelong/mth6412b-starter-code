using Logging

function test_phase4(instance::String; plot_results::Bool=false)
    filename = "instances/stsp/" * instance
    G = read_stsp(filename)
    known_opt = get_optimal(instance)
    test_phase4(G, known_opt; plot_results)
end

function test_phase4(G::Graph{T,U}, known_opt::Float32; plot_results::Bool=false) where {T,U}
    Base.println("### Test des méthodes de la phase 4 sur l'instance ", G.name, " ###")

    Base.println("Coût optimal connu | ", known_opt)

    # Test de RSL
    rsl_tour = rsl(G)
    rsl_cost = tour_cost(G, rsl_tour)
    Base.println("1. RSL")
    Base.println("Coût de la tournée proposée | ", rsl_cost)
    Base.println("RSL/opt (%) | ", rsl_cost / known_opt * 100)

    plot_results && plot_tour(G, rsl_tour)

    Base.println("\n")

    # Test de HK
    #=  hk_tour = held_karp(G)
    hk_cost = tour_cost(G, hk_tour)
    Base.println("2. Held & Karp")
    Base.println("Coût de la tournée proposée | ", hk_cost)
    Base.println("HK/opt (%) | ", hk_cost / known_opt * 100) =#
end