export oneTree, hk

function oneTree(G::Graph{T,U}, node_id::String; method = "Prim", root_id::Union{Nothing, String} = nothing) where{T, U}
  if method == "Prim"
    if isnothing(root_id)
      cost, edges = prim(G, node_ignore_id = [node_id])
    else
      cost, edges = prim(G, root_id, node_ignore_id = [node_id])
    end
  elseif method == "Kruskal"
    cost, edges = kruskal(G, node_ignore_id = [node_id])
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
    if edge.data <= min_edge_weight_1

      min_edge_2 = min_edge_1
      min_edge_weight_2 = min_edge_weight_1
      min_edge_1 = edge
      min_edge_weight_1 = edge.data

    elseif edge.data <= min_edge_weight_2

      min_edge_weight_2 = edge.data
      min_edge_2 = edge

    end
  end
  push!(edges, min_edge_1)
  push!(edges, min_edge_2)
  cost += min_edge_1.data + min_edge_2.data
  return cost, edges
end

function hk(G::Graph{T,U}; root_id::Union{Nothing, String}, method = "Prim") where{T, U}
  if isnothing(root_id) 
    root_id = rand(keys(G.nodes))
  end

  edges = oneTree(G, root_id, method = method)
  return nothing
end