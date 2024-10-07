export Tree, Forest

mutable struct Tree
  parent_id::String
  size::Int64
end

mutable struct Forest
  trees::Dict{String,Tree}
end


function Forest(G::Graph{T, U}) where{T, U}
  trees = Dict{String, Tree}()
  for (node_id, node) in G.nodes
    trees[node_id] = Tree(node_id, 1)
  end
  return Forest(trees)
end

function find(forest::Forest, node_id::String)
  trees = forest.trees
  head_id = node_id
  head_parent = trees[head_id].parent_id
  while head_parent ≠ head_id
    head_parent = trees[trees[head_id].parent_id].parent_id
    head_id = trees[head_id].parent_id
  end
  return head_id
end

function merge(forest::Forest, root_id1::String, root_id2::String)
  trees = forest.trees
  if trees[root_id1].size > trees[root_id2].size
    trees[root_id2].parent_id = root_id1
    trees[root_id1].size = trees[root_id1].size + trees[root_id2].size
  else
    trees[root_id1].parent_id = root_id2
    trees[root_id2].size = trees[root_id2].size + trees[root_id1].size
  end
  
end