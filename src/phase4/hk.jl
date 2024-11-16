export oneTree, hk

function oneTree(
  G::Graph{T,U}, 
  node_id::String; 
  method = "Prim", 
  root_id::Union{Nothing, String} = nothing, 
  p::Dict{String, U} = Dict{String, U}(node_id => U(0) for node_id in keys(G.nodes))
  ) where{T, U}
  if method == "Prim"
    if isnothing(root_id)
      cost, edges = prim(G, node_ignore_id = [node_id], p = p)
    else
      cost, edges = prim(G, root_id, node_ignore_id = [node_id], p = p)
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

function hk(
  G::Graph{T,U}, 
  start_node_id::Union{Nothing, String};
  method = "Prim", 
  root_id::Union{Nothing, String} = nothing
  ) where{T, U}

  # convert G{T, U} to G{T, Float64}
  if U != Float64 # TODO add a more efficient converter
    G_bis = Graph(G.name, collect(values(G.nodes)), [Edge(edge.name,Float64(edge.data), edge.node1_id, edge.node2_id) for edge in values(G.edges)])
    G = G_bis
  end

  period = div(nb_nodes(G),2)
  t = 1
  first_period = true
  w_increases = true
  w_prev = -Inf
  w = -Inf

  k = 0
  W = -Inf
  p = Dict{String, Float64}(node_id => 0.0 for node_id in keys(G.nodes))
  v = Dict{String, Int64}(node_id => -2 for node_id in keys(G.nodes))
  if isnothing(start_node_id)
    start_node_id = rand(keys(G.nodes))
  end

  while k < 50
    cost, edges = oneTree(G, start_node_id, method = method, root_id = root_id, p = p)
    
    w_prev = w
    w = cost - 2*sum(values(p))

    if w <= w_prev
      w_increases = false
    end

    for edge in edges
      v[edge.node1_id] += 1
      v[edge.node2_id] += 1
    end

    if norm(values(v), 1) == 0
      println(norm(values(v), 1))
      return edges
    end
    # Update t

    if k != 0 && k%period == 0  #Rule 2
      first_period = false
      t = t/2
      div(period,2)
    elseif k%period == period-1 && w_prev < w #Rule 5
      period = 2*period
    elseif first_period && w_increases && k > 0 #Rule 4
      t *= 2
    end

    for key in keys(v)
      p[key] = p[key] + t*v[key]
      v[key] = -2 
    end
    k = k + 1

  end
end