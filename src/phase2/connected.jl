export Tree, Forest

"""Type representant un arbre comme l'identifiant d'un parent et une taille d'arbre.

L'identifiant d'un parent dérive de l'identifiant du noeud d'un graphe. 
La taille d'un arbre est définie comme le nombre d'arbres qui ont cet arbre comme parent.
Ce type est principalement utile pour le type "Forest".
"""
mutable struct Tree
  parent_id::String
  size::Int64
end

"""Type representant une forêt comme un ensemble d'identifiants de noeuds pointant vers des arbres.

Les identifiants dérivent des identifiants des noeuds d'un graphe.
A partir de l'identifiant du noeud d'un graphe, cette structure permet de trouver l'arbre associé dans le dictionnaire "trees".
Si l'identifiant d'un noeud pointe vers un arbre dont le parent a le même identifiant, alors ce noeud est une "racine". 
Les racines de l'arbre sont utiles pour les fusionner et pour vérifier l'existence de cycles.
Voir la documentation de la fonction "merge(forest::Forest, root_id1::String, root_id2::String)" pour plus de détails.
"""
mutable struct Forest
  trees::Dict{String,Tree}
end

"""Constructeur du type "Forest".

Initialement, chaque arbre associé à chaque identifiant de noeud est une "racine" de taille 1.
"""
function Forest(G::Graph{T, U}) where{T, U}
  trees = Dict{String, Tree}()
  for (node_id, node) in G.nodes
    trees[node_id] = Tree(node_id, 1)
  end
  return Forest(trees)
end

"""Fonction permettant de trouver la "racine" de l'arbre associé à l'identifiant d'un noeud.

La fonction itère de parent en parent jusqu'à trouver un identifiant dont le parent est lui-même.
"""
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

"""Fonction permettant de fusionner deux arbres à partir de deux identifiants qui ont la propriété d'être des "racines".

La fusion s'opère en redéfinissant le parent d'une "racine" par l'autre "racine".
Pour choisir quelle racine prend l'autre racine comme enfant, la taille des arbres associé est comparée ; l'arbre de plus grande taille englobe l'autre.
"""
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