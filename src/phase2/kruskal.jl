export kruskal

"""
	kruskal(G; mode)

Implémentation de l'algorithme de Kruskal pour identifier un arbre de recouvrement minimal d'un graphe. Renvoie un tuple contenant le coût et une liste des arêtes formant l'arbre de poids minimal. Si le graphe n'est pas connexe, une erreur est renvoyée.

# Arguments
- `G` (`Graph`): le graphe dans lequel il faut identifier un arbre de recouvrement minimal
- `mode` (`String="size"`): (`"size"` ou `"rank"`). Précise le mode d'union entre les composantes connexes qui doit être utilisé.

# Type de retour
`Float64`, `Vector{Edge}`

# Exemples
```julia-repl
julia> kruskal(graph, mode="rank")
```
"""
function kruskal(G::Graph{T,U}; mode::String="size") where {T,U}

  ## Construct the initial forest
  F = Forest(G; mode=mode)
  cost = U(0)
  edges = Edge{U}[]

  ## Order the edges
  sorted = sort(collect(G.edges), by=x -> x[2].data)

  k = 1
  while F.num_roots > 1 && k ≤ length(sorted)
    edge = sorted[k][2]

    node1_id = edge.node1_id
    node2_id = edge.node2_id

    root_node1 = find(F, node1_id)
    root_node2 = find(F, node2_id)

    if root_node1 ≠ root_node2 # L'arête n'ajoute pas de cycle.
      F.num_roots = F.num_roots - 1
      cost = cost + edge.data
      merge!(F, root_node1, root_node2; mode=mode)
      push!(edges, edge)
    end

    k = k + 1
  end

  # Toutes les arêtes ont été explorées mais il reste deux composantes connexes ne pouvant pas être fusionnées.
  if k > length(sorted)
    error("Kruskal: Graph is not connected.")
  end
  return cost, edges

end