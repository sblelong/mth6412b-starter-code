"""Type abstrait représentant tous types d'arbres"""
abstract type AbstractTree{T,U} end

"""Type représentant un arbre.

Requis :
- Doit pouvoir être initialisé simplement à partir de la structure de graphe construite
- Les noeuds pointent vers leur parent ?
- On peut identifier facilement la racine de l'arbre
- La construction d'un arbre à partir d'une liste de noeuds et d'arêtes (les noeuds sont redondants avec les arêtes ?) vérifie si l'ensemble forme bien un arbre (non-orienté, acyclique et connexe)
"""
mutable struct Tree{T,U} <: AbstractTree{T,U}
    nodes::Dict{String,Node{T}}
    edges::Dict{String,Edge{U}}
    adjacency::Dict{String,Vector{Tuple{String,U}}}
    root_id::String
end

function Tree(nodes::Vector{Node{T}}, edges::Vector{Edge{U}}, adjacency::Adjacency) where {T,U}

end

mutable struct ConnectedComponent{T,U}

end