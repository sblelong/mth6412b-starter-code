export kruskal, forest

function forest(G::Graph{T, U}) where{T, U}
  forest = Dict{String, Tree{T, U}}()
  for (node_id, node) in G.nodes
    forest[node_id] = Tree(Dict{String, TreeNode{T}}(node.name => TreeNode(node)), Dict{String, Edge{U}}(), node.name)
  end
  return forest
end

function kruskal(G::Graph{T, U}) where{T, U}

  ## Construct the initial forest
  F = forest(G)

  ## Order the edges
  sorted = sort(collect(G.edges), by = x -> x[2].data)
  println(sorted)

  k = 1
  while length(F) > 1 && k ≤ length(sorted)
    edge = sorted[k][2]

    # Merge forests + check cycle
    k = k + 1
  end

end