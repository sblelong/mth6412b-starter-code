export prim

function prim(G::Graph{T, U}) where{T, U}
  init_node_id = rand(keys(G.nodes))
  return prim(G, init_node_id)
end

function prim(G::Graph{T,U}, init_node_id::String) where {T, U}

	## TODO check init_node in G + add function to only call node id
  edges = Edge{U}[]
	min_weights = PrimPriorityQueue{U}()
	min_weights.order = "min"
	nodes = keys(G.nodes)
	adjacency = G.adjacency

	for node in nodes
		min_weights.items[node] = node == init_node_id ? 0 : typemax(U)
	end
	
	cost = 0
	while !is_empty(min_weights)

		u, weight = popfirst!(min_weights)
		if weight == typemax(U)
			error("Prim: Graph is not connected.")
		end
		cost += weight
		for edge in adjacency[u]
      weight = edge.data
      v = edge.node1_id == u ? edge.node2_id : edge.node1_id
			if haskey(min_weights.items, v)
				if weight < min_weights.items[v] 
          push!(edges,edge)
					min_weights.items[v] = weight 
				end
			end
		end

	
	end

	return cost, edges
end