import Base.show

"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{T} end

"""Type représentant les arêtes d'un graphe.

Exemple:

        arête = Edge("James", [π, exp(1)])
        arête = Edge("Kirk", "guitar")
        arête = Edge("Lars", 2)

"""

mutable struct Edge{T} <: AbstractEdge{T}
    node_1::AbstractNode{T}
    node_2::AbstractNode{T}
end



"""Affiche un noeud."""
function show(edge::AbstractEdge{T}) where T
  println("Edge linking ", edge.node_1.name, " with ", edge.node_2.name)
end