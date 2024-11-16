export rsl

"""
    rsl(G; mst_method, root_method)

Applique l'algorithme de Rosenkrantz, Stearns et Lewis sur un graphe complet pour identifier une tournée de coût au plus le double de l'optimal possible. Des méthodes sont laissées au choix de l'utilisateur : celle permettant d'obtenir l'arbre minimal de recouvrement, et celle permettant de choisir la racine de cet arbre.

# Arguments
- `G` (`Graph`): le graphe dans lequel une tournée minimale est recherchée
- `mst_method` (`String`): méthode pour le calcul de l'arbre de recouvrement minimal. Valeurs possibles: [`"prim", "kruskal"`]
- `root_method` (`String`): méthode pour déterminer la racine de l'arbre de recouvrement minimal. Valeurs possibles: [`"random"`]
"""
function rsl(G::Graph{T,U}; mst_method::String="prim", root_method::String="random") where {T,U}
    # 1. Choix d'un noeud comme racine de l'arbre de recouvrement
    # Étape defférée ici pour garder le contrôle, même si elle est incluse dans Kruskal et Prim.

    if root_method == "random"
        root_id = rand(keys(G.nodes))
    else
        error("Within RSL procedure: method $root_method to initialize is unknown.")
    end

    # 2. Construction de l'arbre de recouvrement minimal

    # 2.1. Kruskal / Prim. Les deux procédures retournent une structure de forêt, qui contient toutes les informations nécessaires.
    if mst_method == "kruskal"
        mst_cost, mst_edges = kruskal(G)
    elseif mst_method == "prim"
        mst_cost, mst_edges, tour = prim(G, root_id; return_rsl=true)
    else
        error("Within RSL procedure: method $mst_method to compute minimal spanning tree is unknown.")
    end
    cost = U(0)
    for (k,node) in enumerate(tour)
      if k < length(tour)
        cost += get_cost(G.cost, tour[k], tour[k+1])
      else 
        cost += get_cost(G.cost, tour[1], tour[k])
      end
    end

    return cost, tour

end