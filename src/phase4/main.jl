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
    rsl_cost, rsl_tour = rsl(G)
    Base.println("1. RSL")
    Base.println("Coût de la tournée proposée | ", rsl_cost)
    Base.println("RSL/opt (%) | ", rsl_cost / known_opt * 100)

    # Test de HK
    hk_cost, hk_tour = hk(G)
    Base.println("2. Held & Karp")
    Base.println("Coût de la tournée proposée | ", hk_cost)
    Base.println("HK/opt (%) | ", hk_cost / known_opt * 100)

    # Comparaison
    Base.println("3. Comparaison")
    Base.println("RSL/HK (%) | ", rsl_cost / hk_cost * 100)

    plot_results && plot_tour(G, rsl_tour)

end