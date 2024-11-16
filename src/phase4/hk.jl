export oneTree, hk

function oneTree(G::Graph{T,U}, node_id::String; method = "Prim", root_id::Union{Nothing, String} = nothing, p::Union{Nothing, Vector{Float64}} = nothing) where{T, U}
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

function hk(G::Graph{T,U}, start_node_id::Union{Nothing, String}; method = "Prim", root_id::Union{Nothing, String} = nothing) where{T, U}
  k = 0
  W = -Inf
  p = zeros(nb_nodes(G))
  v = Dict{String, Int64}(node_id => -2 for node_id in keys(G.nodes))
  if isnothing(start_node_id)
    start_node_id = rand(keys(G.nodes))
  end

  while k < 5
    cost, edges = oneTree(G, start_node_id, method = method, root_id = root_id, p = p)
    w = cost - 2*sum(p)
    W = max(W, w)

    for edge in edges
      v[edge.node1_id] += 1
      v[edge.node2_id] += 1
    end
    println(sum(values(v)))
    if norm(values(v), 1) == 0
      return
    end

    t = 100/(k + 1)

    p .= p .+ t.*values(v)

    for key in keys(v)
      v[key] = -2 
    end
    k = k + 1

  end
  
end