export kruskal

function kruskal(G::Graph{T, U}) where{T, U}

  ## Construct the initial forest
  F = Forest(G)
  num_roots = length(G.nodes)
  cost = 0
  edges = Edge{U}[] 

  ## Order the edges
  sorted = sort(collect(G.edges), by = x -> x[2].data)

  k = 1
  while num_roots > 1 && k ≤ length(sorted) # length(sorted) = nb d'aretes
    edge = sorted[k][2]

    node1_id = edge.node1_id
    node2_id = edge.node2_id

    root_node1 = find(F, node1_id)
    root_node2 = find(F, node2_id)

    if root_node1 ≠ root_node2
      num_roots = num_roots - 1
      cost = cost + edge.data
      merge(F, root_node1, root_node2)
      push!(edges, edge)
    end

    k = k + 1
  end
  if k > length(sorted)
    @error "Kruskal: Graph is not connected."
  end
  return cost, edges

end