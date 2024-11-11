export prim

"""
  prim(G)

Implémentation de l'algorithme de Prim, le premier noeud est choisi aléatoirement parmi les noeuds du graphe.
Si le graphe n'est pas connexe, une erreur est renvoyée.

# Arguments
- G(`Graph`): le graphe sur lequel on exécute l'algorithme de Prim
"""
function prim(G::Graph{T,U}; return_parents::Bool=false) where {T,U}
  init_node_id = rand(keys(G.nodes))
  return prim(G, init_node_id; return_parents)
end

"""
  prim(G, init_node_id)

Implémentation de l'algorithme de Prim.
Si le graphe n'est pas connexe, une erreur est renvoyée.

# Arguments
- G(`Graph`): le graphe sur lequel on exécute l'algorithme de Prim
- init_node_id (`String`): l'identifiant du noeud initial
"""
function prim(G::Graph{T,U}, init_node_id::String; return_parents::Bool=false) where {T,U}

  edges = Edge{U}[]
  min_weights = PrimPriorityQueue{U}()
  min_weights.order = "min"
  nodes = keys(G.nodes)
  adjacency = G.adjacency
  parents = Dict{String,Union{Edge{U},Nothing}}()

  # 1. Initialisation de la file de priorité
  for node in nodes
    min_weights.items[node] = node == init_node_id ? 0 : typemax(U)
    parents[node] = nothing
  end

  cost = U(0)

  # 2. Vider la file de priorité
  while !is_empty(min_weights)

    # 2.1. Extraire la paire (noeud, poids) dont le poids de raccord à l'arbre est minimal.
    u, weight = popfirst!(min_weights)
    !isnothing(parents[u]) && push!(edges, parents[u])

    # Si le plus faible poids restant est ∞, il existe une composante non connectée au reste du graphe.
    if weight == typemax(U)
      error("Prim: Graph is not connected.")
    end

    # 2.2. L'arête a intégré l'arbre de recouvrement : son poids est ajouté au poids total.
    cost += weight

    # 2.3. Tous les noeuds reliés au noeud inséré voient leurs poids minimaux d'insertion mis à jour.
    for edge in adjacency[u]
      weight = edge.data
      v = edge.node1_id == u ? edge.node2_id : edge.node1_id
      if haskey(min_weights.items, v)
        # Si le noeud adjacent à celui inséré n'est pas encore dans l'arbre et que le poids de l'arête les reliant est inférieur à la clé associée dans la file de priorité...
        if weight < min_weights.items[v]
          # ... ce poids devient le nouveau poids minimal d'insertion et son parent est le noeud qui vient d'être inséré.
          min_weights.items[v] = weight
          parents[v] = edge
        end
      end
    end

  end

  return return_parents ? (cost, edges, parents) : (cost, edges)

end