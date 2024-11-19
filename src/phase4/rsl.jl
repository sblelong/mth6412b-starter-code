export rsl

"""
    rsl(G; root_method, root_id)

Applique l'algorithme de Rosenkrantz, Stearns et Lewis sur un graphe complet pour identifier une tournée de coût au plus le double de l'optimal possible. Des méthodes sont laissées au choix de l'utilisateur : celle permettant d'obtenir l'arbre minimal de recouvrement, et celle permettant de choisir la racine de cet arbre.

# Arguments
- `G` (`Graph`): le graphe dans lequel une tournée minimale est recherchée
- `root_method` (`String`): méthode pour déterminer la racine de l'arbre de recouvrement minimal. Valeurs possibles: [`"random"`]
"""
function rsl(G::Graph{T,U}; root_method::String="random", root_id::Union{Nothing,String}=nothing) where {T,U}

    # 1. Choix d'un noeud comme racine de l'arbre de recouvrement
    # Étape defférée ici pour garder le contrôle, même si elle est incluse dans Kruskal et Prim.
    if root_method == "random"
        root_id = rand(keys(G.nodes))
    elseif root_method == "choice"
        if isnothing(root_id)
            error("Within RSL procedure: asked to choose the root but no root_id provided.")
        end
    else
        error("Within RSL procedure: method $root_method to initialize is unknown.")
    end

    # 2. Construction de l'arbre de recouvrement minimal

    # Prim. Retournen une structure de forêt, qui contient toutes les informations nécessaires.
    mst_cost, mst_edges, tour = prim(G, root_id; return_rsl=true)

    push!(tour, tour[1])

    # 3. Calcul du coût de la tournêe
    cost = tour_cost(G, tour)

    return cost, tour

end