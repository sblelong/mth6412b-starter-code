import Base.show

"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{T} end

"""Type représentant les arêtes d'un graphe.

"""

mutable struct Edge{T} <: AbstractEdge{T}
    name::String
    data::T
    node1::AbstractNode{T}
    node2::AbstractNode{T}
end

function Edge(node1::Node{T},node2::Node{T}) where T
    return Edge(
        node1.name*"-"*node2.name,
        T(0),
        node1,
        node2
    )
end



"""Affiche un noeud."""
function show(edge::AbstractEdge{T}) where T
  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", weight: ", edge.data)
end