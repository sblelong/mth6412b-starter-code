export one_tree, hk, find_tree_leaves

"""
    find_tree_leaves(G, edges)

Identifie les feuilles d'un arbre de recouvrement minimal d'un graphe.
Fonction utilisée pour l'heuristique de Held et Karp sur le choix du noeud "spécial" d'un 1-arbre.

# Arguments
- `G` (`Graph{T,U}`) : le graphe dont est issu l'arbre de recouvrement minimal.
- `edges` (`Vector{Edge{U}}`) : l'ensemble des arêtes formant l'arbre de recouvrement minimal.

# Type de retour
`Vector{String}`. La liste des identifiants des feuilles de l'arbre de recouvrement minimal.
"""
function find_tree_leaves(G::Graph{T,U}, edges::Vector{Edge{U}})::Vector{String} where {T,U}
    leaves = Vector{String}()

    for node_id in keys(G.nodes)
        children = find_children(edges, node_id)
        if length(children) ≤ 1
            push!(leaves, node_id)
        end
    end
    return leaves
end

"""
    one_tree(G; special_node_id, mst_method, root_id, π, return_special_node)

Fonction fondamentale dans l'implémentation de l'algorithme de montée de Held et Karp.
Détermine un 1-arbre minimal dans le graphe passé, selon 2 heuristiques :
- Si un identifiant est passé pour le noeud "spécial", le 1-arbre est construit autour de ce noeud.
- Sinon, ce noeud est choisi après calcul de l'arbre de recouvrement minimal comme celui ayant la plus grande distance à son deuxième plus proche voisin.

La fonction permet également d'appliquer une translation sur les poids du graphe avant d'en calculer un arbre de recouvrement minimal.

# Arguments
- `G` (`Graph{T,U}`) : le graphe sur lequel travaille HK.
- `special_node_id` (optionnel, `String`) : l'identifiant du noeud "spécial" du 1-arbre à calculer.
- `mst_method` (optionnel, `String`) : l'algorithme à utiliser pour calculer un arbre de recouvrement minimal. Valeurs possibles : `["prim", "kruskal"]`.
- `root_id` (optionnel, `String`) : l'identifiant du noeud qui doit être utilisé comme racine de l'arbre de recouvrement minimal.
- `π` (optionnel, `Dict{String, U}`) : les translations des poids pour le calcul de l'arbre de recouvrement minimal.
- `return_special_node` (optionnel, `Bool`) : si passé à `true`, la fonction renverra l'identifiant du noeud "spécial" du 1-arbre. Utile dans le cas où la seconde heuristique est employée.

# Type de retour
`Tuple{U, Vector{Edge{U}} (, String)}`. Tuple contenant le coût du 1-arbre minimal obtenu, la liste des arêtes le constituant et optionnellement l'identifiant du noeud "spécial" du 1-arbre.
"""
function one_tree(
    G::Graph{T,U};
    special_node_id::Union{String,Nothing}=nothing,
    mst_method="prim",
    root_id::Union{Nothing,String}=nothing,
    π::Dict{String,U}=Dict{String,U}(id => U(0) for id in keys(G.nodes)),
    return_special_node::Bool=false
) where {T,U}
    if !isnothing(special_node_id)
        if mst_method == "prim"
            if isnothing(root_id)
                cost, edges = prim(G, node_ignore_id=[special_node_id], p=π)
            else
                cost, edges = prim(G, root_id, node_ignore_id=[special_node_id], p=π)
            end
        elseif mst_method == "kruskal"
            cost, edges = kruskal(G, node_ignore_id=[special_node_id], p=π)
        else
            error("1-Tree : please select a mst_method between 'Kruskal' and 'Prim' for the minimum spanning tree algorithm.")
        end

        !haskey(G.nodes, special_node_id) && error("1-Tree : 1-Tree can not be computed because the node id is unknown.")
        length(G.adjacency[special_node_id]) < 2 && error("1-Tree : 1-Tree can not be computed because the node id has a degree less than 2.")

        min_edge_1 = nothing
        min_edge_2 = nothing
        min_edge_weight_1 = Inf
        min_edge_weight_2 = Inf

        for edge in G.adjacency[special_node_id]
            if edge.node1_id != edge.node2_id && edge.data <= min_edge_weight_1

                min_edge_2 = min_edge_1
                min_edge_weight_2 = min_edge_weight_1
                min_edge_1 = edge
                min_edge_weight_1 = edge.data

            elseif edge.node1_id != edge.node2_id && edge.data <= min_edge_weight_2

                min_edge_weight_2 = edge.data
                min_edge_2 = edge

            end
        end
        push!(edges, min_edge_1)
        push!(edges, min_edge_2)
        cost += min_edge_1.data + min_edge_2.data
        return cost, edges
    else # heuristic where the special node for the 1-Tree is not fixed.
        if mst_method == "prim"
            if isnothing(root_id)
                cost, edges = prim(G, p=π)
            else
                cost, edges = prim(G, root_id, p=π)
            end
        elseif mst_method == "kruskal"
            cost, edges = kruskal(G, p=π)
        else
            error("1-Tree : please select a mst_method between 'Kruskal' and 'Prim' for the minimum spanning tree algorithm.")
        end

        # Trouver les feuilles de l'arbre
        leaves = find_tree_leaves(G, edges)

        # Trouver la feuille ayant la plus longue distance à son second plus proche voisin
        current_max_idx = ""
        current_max = typemin(U)
        current_sorted_edges = nothing
        for leaf in leaves
            sorted_incident_edges = sort(G.adjacency[leaf], by=edge -> edge.data)
            if sorted_incident_edges[2].data > current_max
                current_max_idx = leaf
                current_max = sorted_incident_edges[2].data
                current_sorted_edges = sorted_incident_edges
            end
        end

        # Pour la feuille identifiée, ajouter l'arête qui la lie à son second plus proche voisin
        push!(edges, current_sorted_edges[2])
        cost += current_sorted_edges[2].data

        return return_special_node ? (cost, edges, current_max_idx) : (cost, edges)
    end
end

"""
    hk(G; start_node_id, mst_method, root_id, max_iters, τ, nesterov_weight, one_tree_heuristic)

Applique l'algorithme de montée de Held et Karp pour déterminer une tournée optimale dans le graphe passé en argument.

# Arguments
- `G` (`Graph`) : le graphe dans lequel une tournée optimale est recherchée
- `start_node_id` (optionnel, `String`) : id du noeud à utiliser comme départ de la tournée
- `mst_method` (optionnel, `String`) : méthode utilisée pour les calculs d'arbres minimaux de recouvrement. Valeurs possibles : `["prim", "kruskal"]`. Défaut : `prim`
- `root_id` (optionnel, `String`) : identifiant permettant d'imposer la racine des arbres de recouvrement minimaux
- `max_iters` (optionnel, `Int`) : nombre maximal d'itérations de l'algorithme
- `τ` (optionnel, `Int`) : proportion de noeuds de degré 2 suffisante pour considérer une solution acceptable
- `nesterov_weight` (optionnel, `Union{Float64, Nothing}`) : poids pour l'accélération à la Nesterov. Si `nothing` est passé, cette heuristique est désactivée. Valeur par défaut : 0.7.
- `one_tree_heuristic` (optionnel, `Bool`) : si passé à `false`, l'heuristique pour le calcul de la racine des 1-arbres minimaux est désactivée. Voir [`one_tree`](@ref).
"""
function hk(
    G::Graph{T,U};
    start_node_id::Union{Nothing,String}=nothing,
    mst_method="prim",
    root_id::Union{Nothing,String}=nothing,
    max_iters::Int=typemax(Int),
    τ::Float64=0.4,
    nesterov_weight::Union{Float64,Nothing}=0.7,
    one_tree_heuristic::Bool=true
) where {T,U}

    # Préalable : conversion de tous les poids en Float64
    if U != Float64 # TODO add a more efficient converter
        G_bis = Graph(G.name, collect(values(G.nodes)), [Edge(edge.name, Float64(edge.data), edge.node1_id, edge.node2_id) for edge in values(G.edges)])
        G = G_bis
    end

    # 1. Initialisations
    cost = nothing
    edges = nothing

    # Utilisation de l'heuristique par périodes
    N = nb_nodes(G)
    period = div(N, 2) # Première période : longueur N/2
    first_period = true

    # Sous-gradients
    v = Dict{String,Int64}(node_id => -2 for node_id in keys(G.nodes))
    v_prev = Dict{String,Int64}(node_id => -2 for node_id in keys(G.nodes))

    t = 1 # Pas de la descente

    # Borne inférieure sur le coût optimal de la tournée
    W = -Inf
    w = -Inf
    w_increases = true

    # Translation des poids des arêtes
    π = Dict{String,Float64}(node_id => 0.0 for node_id in keys(G.nodes))

    # Choix du noeud de départ de la tournée
    if isnothing(start_node_id)
        start_node_id = rand(keys(G.nodes))
    end

    k = 0

    while period > 0 && t > 1e-3 && k < max_iters

        # 2. Calcul d'un 1-arbre minimal avec translation des poids
        cost, edges = one_tree_heuristic ? one_tree(G, mst_method=mst_method, root_id=root_id, π=π) : one_tree(G, special_node_id=start_node_id, mst_method=mst_method, root_id=root_id, π=π)

        # 3. Calcul de la borne inférieure obtenue sur le coût de la tournée optimale dans le problème originel
        w = cost - 2 * sum(values(π))
        w_increases = w > W
        # 4. MàJ de la borne
        W = max(W, w)

        # 5. MàJ du sous-gradient
        for edge in edges
            v[edge.node1_id] += 1
            v[edge.node2_id] += 1
        end

        # 6. Critère d'arrêt sur les degrés des noeuds
        if norm(values(v), 1) <= τ * N
            tour = preorder(edges, start_node_id)
            push!(tour, tour[1])
            cost = tour_cost(G, tour)
            return cost, tour
        end

        # 7. Mise à jour du pas
        ## Heuristique 2
        if k > 0 && k % period == 0
            first_period = false
            t = t / 2
            div(period, 2)

            ## Heuristique 5
        elseif k % period == period - 1 && w_increases
            period = 2 * period

            ## Heuristique 4
        elseif first_period && w_increases && k > 0
            t *= 2
        end

        # 8. Mise à jour du vecteur de translation des poids
        for key in keys(v)
            if k > 0
                if !isnothing(nesterov_weight)
                    π[key] = π[key] + t * (nesterov_weight * v[key] + (1 - nesterov_weight) * v_prev[key])
                else
                    π[key] = π[key] + t * v[key]
                end
            else
                π[key] = π[key] + t * v[key]
            end
            v_prev[key] = v[key]
            v[key] = -2
        end
        k = k + 1

    end

    tour = preorder(edges, start_node_id)
    push!(tour, tour[1])
    cost = tour_cost(G, tour)
    return cost, tour

end