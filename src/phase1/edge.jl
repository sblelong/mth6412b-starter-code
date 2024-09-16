import Base.show

"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{T, U} end

"""Type représentant les arêtes d'un graphe.

"""

mutable struct Edge{T, U} <: AbstractEdge{T, U}
    name::String
    data::U
    node1::AbstractNode{T}
    node2::AbstractNode{T}
end

function Edge(node1::Node{T}, node2::Node{T}, weight::U) where{T, U}
    Edge(node1.name*"-"*node2.name, weight, node1, node2)
end



"""Affiche un noeud."""
function show(edge::AbstractEdge{T, U}) where {T, U}
  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", weight: ", edge.data)
end