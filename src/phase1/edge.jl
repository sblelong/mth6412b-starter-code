export Edge,show

"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{U} end

"""Type représentant les arêtes d'un graphe.

  Exemple:

        arête = Edge("E411", 40000, "Louvain-la-Neuve", "Namur")
        arête = Node("E40", 35000, "Bruxelles", "Gand")
        arête = Node("Meuse", 45000, "Liège", "Namur")
"""

mutable struct Edge{U} <: AbstractEdge{U}
    name::String
    data::U
    node1_id::String
    node2_id::String
end

function Edge(node1_id::T, node2_id::T, weight::U) where{T <: Number, U}
  Edge(string(node1_id)*"-"*string(node2_id), weight, string(node1_id), string(node2_id))
end

function Edge(node1_id::String, node2_id::String, weight::U) where{U}
    Edge(node1.name*"-"*node2.name, weight, node1_id, node2_id)
end

"""Affiche un noeud."""
function show(edge::AbstractEdge{U}) where {U}
  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", weight: ", edge.data)
end