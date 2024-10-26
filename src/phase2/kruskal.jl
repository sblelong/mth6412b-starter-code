export kruskal

"""Implémentation de l'algorithme de Kruskal pour les arbres recouvrants de poids minimal.

En entrée, la fonction reçoit un graphe. 
La fonction renvoie un tuple contenant le coût et une liste des arêtes formant l'arbre de poids minimal.

Si le graphe n'est pas connexe, une erreur est renvoyée.
"""
function kruskal(G::Graph{T,U}) where {T,U}

  ## Construct the initial forest
  F = Forest(G)
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
      merge!(F, root_node1, root_node2)
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