"""
    update!(tree, π, G ; mst_method)

Mise à jour du 1-arbre courant à partir du vecteur π des poids à ajouter. La méthode de calcul du nouvel MST peut être passée en argument.
*Attention* On suppose ici que les noms des noeuds sont des nombres que l'on peut transformer en Int de façon que π[Int(node_id)] soit le poids supplémentaire associé au noeud d'id `node_id`.
"""
# TODO: cette signature est à chier, il ne devrait pas y avoir besoin de passer un graphe en argument. Dans l'immédiat, c'est plus simple pour lancer Prim.
function update!(tree::Dict{String,Edge{U}}, π::Vector{U}, G::Graph{T,U}; mst_method::String="prim", kwargs...) where {T,U}

    aux_graph = deepcopy(G)

    # 1. Ajouter les poids aux arétes
    for (key, edge) in aux_graph.edges
        # TODO: généraliser l'ajout des poids dans le cas où les noms des noeuds sont fancy ?
        node1_key = parse(Int, edge.node1_id)
        node2_key = parse(Int, edge.node2_id)

        edge.data += (π[node1_key] + π[node2_key])
    end

    # 2. Calculer le nouvel MST à partir de ces nouveaux poids
    if mst_method == "prim"
        root = rand(keys(G.nodes)) # TODO: attention, initialisation aléatoire de Prim
        prim_cost, prim_edges = prim(aux_graph, root; kwargs)
    end

    # 3. Ajout des 2 arêtes de plus faibles coûts incidentes au noeud de départ
    sorted_root_neighbors = sort(G.adjacency[root], by=x -> x.data)
    push!(prim_edges, sorted_root_neighbors[:2])

    # Construction du dictionnaire à retourner
    new_tree = Dict([(edge.name, edge) for edge in prim_edges])

    tree = new_tree
end

function update(step::Float64, improved_bounds::Bool; kwargs)
    return improved_bounds ? step * 2 : step / 2
end

"""
Calcule le degré de chaque noeud dans le 1-arbre `tree` extrait du graphe `G`.
**Attention** suppose que les noeuds de `G` ont des id numérotés
"""
function compute_degrees(tree::Dict{String,Edge{U}}, G::Graph{T,U}) where {T,U}

    degrees = zeros(Int, length(G.nodes))
    tree_edges = collect(values(tree))

    for node_id in keys(G.nodes)
        incident_edges = G.adjacency[node_id]
        common_edges = intersect(incident_edges, tree_edges)
        degrees[parse(Int, node_id)] += length(common_edges)
    end

    return degrees

end

"""
    hk(G; kwargs)

# Arguments
- G: Graph
- kwargs
    - mst_method::String
    - update!(tree): calculer T_π^k en fonction de T^π_{k-1}
    - arguments de la fonction d'update! de t_k
    - w1 pour l'accélération de Nesterov
"""
function hk(G::Graph{T,U}; tol::Int=2, kwargs...) where {T,U}
    # Prendre t0 = M/k

    N = length(G.nodes) # Taille de la tournée à déterminer

    # 1. Initialisation des variables
    # TODO intialiser v, T également
    π = zeros(U, N)
    W = typemin(U)
    t = 1.0 # TODO: initialisation arbitraire et temporaire
    v = typemax(Int) # Arbitrairement : au début, les noeuds sont de degrés maximaux
    tree = G.edges # TODO: pour l'instant, un 1-arbre sera implémenté comme le sont les arétes d'un graphe (Dict{String, Edge{U}})

    k = 0

    # Condition d'arrêt : tolérance atteinte sur v
    while maximum(v) > tol
        # 2. Calculer un 1-arbre minimal avec le π courant
        update!(tree, π, G; kwargs)

        # 3. Calculer le coût de la tournée dans l'arbre original (pas celui après ajout des π_i)
        w = sum([edge.data for edge in values(tree)]) - 2 * sum(π)

        # 4. Mettre à jour la meilleure borne inférieure sur le coût minimal. Si celui-ci n'est pas améliorè, le pas t courant est refusé et on continue la procédure en imposant un autre pas.
        W = max(W, w)
        improved_bound = W == w

        # 5. Calcul du sous-gradient du problème
        v = compute_degrees(tree, G) .- 2

        # 6. Critère d'arêt : ignorer

        # 7. Mettre à jour la taille du pas
        t = update(t, improved_bound; kwargs)

        # 8. Mettre à jour π (simple addition : descente de gradient)
        π = π .+ t .* v

        k += 1
        if k % 100 == 0
            println("Iteration $k | max(v)=", maximum(v), " | t: $t | bound: $W")
        end
    end

    # Retourner la tourněe minimale, et son coût ?
    return tree

end