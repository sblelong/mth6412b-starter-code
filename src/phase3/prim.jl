export prim

"""
  prim(G)

Implémentation de l'algorithme de Prim, le premier noeud est choisi aléatoirement parmi les noeuds du graphe.
Si le graphe n'est pas connexe, une erreur est renvoyée.

# Arguments
- G(`Graph`): le graphe sur lequel on exécute l'algorithme de Prim
"""
function prim(G::Graph{T, U}) where{T, U}
  init_node_id = rand(keys(G.nodes))
  return prim(G, init_node_id)
end

"""
  prim(G, init_node_id)

Implémentation de l'algorithme de Prim.
Si le graphe n'est pas connexe, une erreur est renvoyée.

# Arguments
- G(`Graph`): le graphe sur lequel on exécute l'algorithme de Prim
- init_node_id (`String`): l'identifiant du noeud initial
"""
function prim(G::Graph{T,U}, init_node_id::String) where {T, U}

  edges = Edge{U}[]
	min_weights = PrimPriorityQueue{U}()
	min_weights.order = "min"
	nodes = keys(G.nodes)
	adjacency = G.adjacency
  parents = Dict{String, Union{Edge{U}, Nothing}}()

	for node in nodes
		min_weights.items[node] = node == init_node_id ? 0 : typemax(U)
    parents[node] = nothing
	end
	
	cost = U(0)
	while !is_empty(min_weights)

  u, weight = popfirst!(min_weights)
  !isnothing(parents[u]) && push!(edges, parents[u])
  
  if weight == typemax(U)
    error("Prim: Graph is not connected.")
  end

  cost += weight
  for edge in adjacency[u]
    weight = edge.data
    v = edge.node1_id == u ? edge.node2_id : edge.node1_id
    if haskey(min_weights.items, v)
      if weight < min_weights.items[v] 
        min_weights.items[v] = weight 
        parents[v] = edge
      end
    end
  end

	
	end

	return cost, edges
end