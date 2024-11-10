export rsl

function rsl(G::Graph{T,U}; root_method::String="random", mst_method::String="prim") where {T,U}
    # 1. Choix d'un noeud comme racine de l'arbre de recouvrement
    # Étape defférée ici pour garder le contrôle, même si elle est incluse dans Kruskal et Prim.

    if root_method == "random"
        root_id = rand(keys(G.nodes))
    else
        error("Within RSL procedure: method $root_method to initialize is unknown.")
    end

    # 2. Construction de l'arbre de recouvrement minimal

    if mst_method == "kruskal"
        mst_cost, mst_edges = kruskal(G)
    elseif mst_method == "prim"
        mst_cost, mst_edges = prim(G, root_id)
    else
        error("Within RSL procedure: method $mst_method to compute minimal spanning tree is unknown.")
    end

    println(mst_edges)

end