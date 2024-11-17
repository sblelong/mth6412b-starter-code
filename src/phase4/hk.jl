export one_tree, hk, find_tree_leaves

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
    one_tree(G; node_id)
"""
function one_tree(
    G::Graph{T,U};
    node_id::Union{String,Nothing}=nothing,
    method="Prim",
    root_id::Union{Nothing,String}=nothing,
    p::Dict{String,U}=Dict{String,U}(node_id => U(0) for node_id in keys(G.nodes))
) where {T,U}
    if !isnothing(node_id)
        if method == "Prim"
            if isnothing(root_id)
                cost, edges = prim(G, node_ignore_id=[node_id], p=p)
            else
                cost, edges = prim(G, root_id, node_ignore_id=[node_id], p=p)
            end
        elseif method == "Kruskal"
            cost, edges = kruskal(G, node_ignore_id=[node_id], p=p)
        else
            error("1-Tree : please select a method between 'Kruskal' and 'Prim' for the minimum spanning tree algorithm.")
        end

        !haskey(G.nodes, node_id) && error("1-Tree : 1-Tree can not be computed because the node id is unknown.")
        length(G.adjacency[node_id]) < 2 && error("1-Tree : 1-Tree can not be computed because the node id has a degree less than 2.")

        min_edge_1 = nothing
        min_edge_2 = nothing
        min_edge_weight_1 = Inf
        min_edge_weight_2 = Inf

        for edge in G.adjacency[node_id]
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
        if method == "Prim"
            if isnothing(root_id)
                cost, edges = prim(G, p=p)
            else
                cost, edges = prim(G, root_id, p=p)
            end
        elseif method == "Kruskal"
            cost, edges = kruskal(G, p=p)
        else
            error("1-Tree : please select a method between 'Kruskal' and 'Prim' for the minimum spanning tree algorithm.")
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

        return cost, edges
    end
end

"""
    hk(G; start_node_id, method, root_id)

Applique l'algorithme de montée de Held et Karp pour déterminer une tournée optimale dans le graphe passé en argument.

# Arguments
- `G` (`Graph`) : le graphe dans lequel une tournée optimale est recherchée
- `start_node_id` (optionnel, `String`) : id du noeud à utiliser comme départ de la tournée
- `method` (optionnel, `String`) : méthode utilisée pour les calculs d'arbres minimaux de recouvrement. Valeurs possibles : `["Prim", "Kruskal"]`. Défaut : `Prim`
- `MAX_ITER` (optionnel, `Int`) : nombre maximal d'itérations de l'algorithme
- `τ` (optionnel, `Int`) : proportion de noeuds de degré 2 suffisante pour considérer une solution acceptable
"""
function hk(
    G::Graph{T,U};
    start_node_id::Union{Nothing,String}=nothing,
    method="Prim",
    root_id::Union{Nothing,String}=nothing,
    MAX_ITER::Int=100,
    τ::Float64=0.4,
    nesterov_weight::Float64=0.7
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
        println("Noeud de départ : $start_node_id")
    end

    k = 0

    while period > 0 && t > 1e-3 && k < MAX_ITER

        # 2. Calcul d'un 1-arbre minimal avec translation des poids
        cost, edges = one_tree(G, method=method, root_id=root_id, p=π)

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
        if norm(values(v), 0) <= τ * N
            #Construct Traversal
            return cost, edges
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
                π[key] = π[key] + t * (nesterov_weight * v[key] + (1 - nesterov_weight) * v_prev[key])
            else
                π[key] = π[key] + t * v[key]
            end
            v_prev[key] = v[key]
            v[key] = -2
        end
        k = k + 1

    end

    return cost, edges
end

####### Ancien code

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
function hk_old(G::Graph{T,U}; tol::Int=2, kwargs...) where {T,U}
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