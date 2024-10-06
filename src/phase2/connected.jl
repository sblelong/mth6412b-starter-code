export TreeNode, Tree

"""Type abstrait représentant tous types d'arbres"""
abstract type AbstractTree{T,U} <: AbstractGraph{T, U} end

"""Type représentant un arbre.

Requis :
- Doit pouvoir être initialisé simplement à partir de la structure de graphe construite
- Les noeuds pointent vers leur parent ?
- On peut identifier facilement la racine de l'arbre
- La construction d'un arbre à partir d'une liste de noeuds et d'arêtes (les noeuds sont redondants avec les arêtes ?) vérifie si l'ensemble forme bien un arbre (non-orienté, acyclique et connexe)
"""
mutable struct TreeNode{T} <: AbstractNode{T}
  name::String
  data::T
  root_id::String
end

function TreeNode(name::String, data::T) where{T} 
  return TreeNode(name, data, name)
end 

function TreeNode(node::Node{T}) where{T}
  return TreeNode(node.name, node.data)
end

mutable struct Tree{T, U} <: AbstractTree{T, U}
  nodes::Dict{String,TreeNode{T}}
  edges::Dict{String,Edge{U}}
  root_id::String
end
