export Tree, Forest

"""Type representant un arbre comme l'identifiant d'un parent, une liste d'identifiants d'enfants et une taille ou un rang d'arbre.

L'identifiant d'un parent dérive de l'identifiant du noeud d'un graphe.
Les identifiants des enfants dérivent de l'identifiant de noeuds d'un graphe.
La taille d'un arbre est définie comme le nombre d'arbres qui ont cet arbre comme parent.
Le rang d'un arbre est un attribut utile pour la procédure d'union de composantes connexes par le rang.
Un seul attribut parmi la taille et le rang n'est pas nul.
Ce type est principalement utile pour le type `Forest`.
"""
mutable struct Tree
  parent_id::String
  child_ids::Vector{String}
  size::Union{Int64,Nothing}
  rank::Union{Int64,Nothing}
end

"""
  Tree(parent_id, value; mode)

Initialise un arbre à partir de l'identifiant de sa racine et d'une valeur de taille et de rang (option choisie par l'argumment `mode`).

# Arguments
- `parent_id` (`String`): l'identifiant du noeud constituant la racine de l'arbre
- `value` (`Int64`): la valeur numérique de la taille ou du rang
- `mode` (`String`="size"): ("size" ou "rank"). L'attribut qui doit être initialisé à la valeur `value` (la taille ou le rang).
"""
function Tree(parent_id::String, value::Int64; mode::String="size")
  mode in ["size", "rank"] || error("When initializing a Tree, the `mode` argument should be 'size' or 'rank'.")
  mode == "size" ? Tree(parent_id, String[], value, nothing) : Tree(parent_id, String[], nothing, value)
end


"""Type representant une forêt comme un ensemble d'identifiants de noeuds pointant vers des arbres.

Les identifiants dérivent des identifiants des noeuds d'un graphe.
A partir de l'identifiant du noeud d'un graphe, cette structure permet de trouver l'arbre associé dans le dictionnaire `trees``.
Si l'identifiant d'un noeud pointe vers un arbre dont le parent a le même identifiant, alors ce noeud est une "racine". 
Les "racines" de l'arbre sont utiles pour les fusionner et pour vérifier l'existence de cycles.

Voir la documentation de la fonction [`merge`](@ref) pour plus de détails.

Le nombre de "racines" contenue dans la forêt est également stocké dans l'attribut `num_roots`.
"""
mutable struct Forest
  trees::Dict{String,Tree}
  num_roots::Int64
end

"""
  Forest(G; mode)

Initialise une forêt de composantes connexes à partir d'un graphe. Un arbre de taille 1 ou de rang 0 est créé par noeud du graphe. Cette fonction est conçue pour servir à l'initialisation de l'algorithme de Kruskal.

# Arguments
- `G` (`Graph`): le graphe à partir duquel construire une forêt de composantes connexes
- `mode` (`String="size"`) : (`"size"` ou `"rank"`). L'attribut à initialiser dans chaque arbre créé
"""
function Forest(G::Graph{T,U}; mode::String="size") where {T,U}
  trees = Dict{String,Tree}()
  mode in ["size", "rank"] || error("When initializing a Forest, the `mode` argument should be 'size' or 'rank'.")
  for (node_id, node) in G.nodes
    trees[node_id] = mode == "size" ? Tree(node_id, 1) : Tree(node_id, 0, mode="rank")
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

import Base.merge!
"""
	merge!(forest, root_id1, root_id2; mode)

Fonction permettant de fusionner deux arbres à partir de deux identifiants qui ont la propriété d'être des "racines". La fusion s'opère en redéfinissant le parent d'une "racine" par l'autre "racine".

Pour choisir quelle racine prend l'autre racine comme enfant, 2 possibilités sont proposées.

### [Union par la taille](https://en.wikipedia.org/wiki/Disjoint-set_data_structure#Union_by_size)
La taille des arbres associés est comparée ; l'arbre de plus grande taille englobe l'autre. Cela nécessite que les attributs `size` des arbres de la forêt ne soient pas nuls.

### Union par le rang
Les rangs sont comparés et incrémentés selon la politique classique d'union par le rang.

# Arguments
- `forest` (`Forest`): forêt dans laquelle se trouvent les 2 arbres à fusionner
- `root_id1` (`String`): identifiant de la racine du premier arbre participant à la fusion
- `root_id2` (`String`): identifiant de la racine du second arbre participant à la fusion
- `mode` (`String="size"`): (`"size"` ou `"rank"`). Indique le critère retenu pour l'union.

# Type de retour
Aucun : fonction *in-place*.
"""
function merge!(forest::Forest, root_id1::String, root_id2::String; mode::String="size")
  trees = forest.trees

  if mode == "size"

    new_root = trees[root_id1].size > trees[root_id2].size ? root_id1 : root_id2
    new_child = trees[root_id1].size > trees[root_id2].size ? root_id2 : root_id1

    trees[new_root].size = trees[new_root].size + trees[new_child].size

  elseif mode == "rank"

    new_root = trees[root_id1].rank > trees[root_id2].rank ? root_id1 : root_id2
    new_child = trees[root_id1].rank > trees[root_id2].rank ? root_id2 : root_id1
    
    # Si les rangs sont égaux, c'est la seconde qui devient parent de la première et son rang augmente de 1.
    if trees[root_id1].rank == trees[root_id2].rank
      trees[new_root].rank += 1
    end

  else
    error("When performing merge on connected components, the `mode` argument should be 'size' or 'rank'.")
  end

  trees[new_child].parent_id = new_root

end

export merge!