export Edge,show, dict

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

"""Construit une arête à partir d'un poids et de deux identifiants de noeud sous forme de nombre."""
function Edge(node1_id::T, node2_id::T, weight::U) where{T <: Number, U}
  Edge(string(node1_id)*"-"*string(node2_id), weight, string(node1_id), string(node2_id))
end

"""Construit une arête à partir d'un poids et de deux identifiants de noeud."""
function Edge(node1_id::String, node2_id::String, weight::U) where{U}
    Edge(node1.name*"-"*node2.name, weight, node1_id, node2_id)
end

"""Affiche un noeud."""
function show(edge::AbstractEdge{U}) where {U}
  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", weight: ", edge.data)
end

"""Construit un dictionnaire représentant l'arête."""
dict(edge::Edge{U}) where{U} = Dict{String, Tuple{String, U}}(edge.node1_id => (edge.node2_id, edge.data), edge.node2_id => (edge.node1_id, edge.data))