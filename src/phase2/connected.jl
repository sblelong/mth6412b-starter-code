export Tree, Forest

"""Type representant un arbre comme l'identifiant d'un parent et une taille d'arbre.

L'identifiant d'un parent dérive de l'identifiant du noeud d'un graphe.
La taille d'un arbre est définie comme le nombre d'arbres qui ont cet arbre comme parent.
Ce type est principalement utile pour le type `Forest`.
"""
mutable struct Tree
  parent_id::String
  size::Int64
end

"""Type representant une forêt comme un ensemble d'identifiants de noeuds pointant vers des arbres.

Les identifiants dérivent des identifiants des noeuds d'un graphe.
A partir de l'identifiant du noeud d'un graphe, cette structure permet de trouver l'arbre associé dans le dictionnaire `trees``.
Si l'identifiant d'un noeud pointe vers un arbre dont le parent a le même identifiant, alors ce noeud est une "racine". 
Les "racines" de l'arbre sont utiles pour les fusionner et pour vérifier l'existence de cycles.

Voir la documentation de la fonction [`merge`](@ref) pour plus de détails.

Le nombre de "racines" contenue dans la forêt est également stockée dans l'attribut `num_roots`.
"""
mutable struct Forest
  trees::Dict{String,Tree}
  num_roots::Int64
end

"""
  Forest(G)

Initialise une forêt de composantes connexes à partir d'un graphe. Un arbre de taille 1 est créé par noeud du graphe. Cette fonction est conçue pour servir à l'initialisation de l'algorithme de Kruskal.

# Arguments
- G (`Graph``): le graphe à partir duquel construire une forêt de composantes connexes
"""
function Forest(G::Graph{T,U}) where {T,U}
  trees = Dict{String,Tree}()
  for (node_id, node) in G.nodes
    trees[node_id] = Tree(node_id, 1)
  end
  return Forest(trees, length(G.nodes))
end

"""
	find(forest, node_id)

Retourne la racine de l'arbre associé au noeud d'identifiant `node_id` dans la forêt `forest`. Itère de parent en parent jusqu'à trouver un identifiant dont le parent est lui-même.

# Arguments
- forest (`Forest`): forêt dans laquelle rechercher l'arbre auquel est rattaché le noeud
- `node_id` (String): identifiant du noeud à rechercher dans la forêt

# Exemple
```julia-repl
julia> find("24", forest)
Tree("7", 12)
# Le noeud d'identifiant "24" est contenu dans l'arbre de la forêt dont la racine est d'identifiant "7", et de taille 12.
```
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

"""
	merge!(forest, root_id1, root_id2)

Fonction permettant de fusionner deux arbres à partir de deux identifiants qui ont la propriété d'être des "racines". La fusion s'opère en redéfinissant le parent d'une "racine" par l'autre "racine". Pour choisir quelle racine prend l'autre racine comme enfant, la taille des arbres associé est comparée ; l'arbre de plus grande taille englobe l'autre. Ce choix est justifié [ici](https://en.wikipedia.org/wiki/Disjoint-set_data_structure#Union_by_size).

# Arguments
- `forest` (`Forest`): forêt dans laquelle se trouvent les 2 arbres à fusionner
- `root_id1` (`String`): identifiant de la racine du premier arbre participant à la fusion
- `root_id2` (`String`): identifiant de la racine du second arbre participant à la fusion

# Type de retour
Aucun : fonction *in-place*.
"""
function merge!(forest::Forest, root_id1::String, root_id2::String)
  trees = forest.trees
  if trees[root_id1].size > trees[root_id2].size
    trees[root_id2].parent_id = root_id1
    trees[root_id1].size = trees[root_id1].size + trees[root_id2].size
  else
    trees[root_id1].parent_id = root_id2
    trees[root_id2].size = trees[root_id2].size + trees[root_id1].size
  end
end