export Edge, show, dict

"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{U} end

"""Type représentant les arêtes d'un graphe.

  Exemple:

        arête = Edge("E411", 40000, "Ottignies-Louvain-la-Neuve", "Namur")
        arête = Edge("E40", 35000, "Bruxelles", "Gand")
        arête = Edge("Meuse", 45000, "Liège", "Namur")
"""
mutable struct Edge{U} <: AbstractEdge{U}
  name::String
  data::U
  node1_id::String
  node2_id::String
end

"""Construit une arête à partir d'un poids et de deux identifiants de noeud sous forme de nombre."""
function Edge(node1_id::T, node2_id::T, weight::U) where {T,U<:Number}
  Edge(string(node1_id) * "-" * string(node2_id), weight, string(node1_id), string(node2_id))
end

"""Construit une arête à partir d'un poids et de deux identifiants de noeud."""
function Edge(node1_id::String, node2_id::String, weight::U) where {U<:Number}
  Edge(node1_id * "-" * node2_id, weight, node1_id, node2_id)
end

"""
		show(edge::AbstractEdge{T,U})

	Affiche une arête.
	"""
function show(edge::AbstractEdge{U}) where {U}
  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", data: ", edge.data)
end

## Matrices d'adjacence

"""Alias de type pour représenter un dictionnaire d'adjacence"""
const Adjacency = Dict{String,Vector{Tuple{String,Edge{U}}}} where{U}

"""Construit un dictionnaire d'adjacence à partir d'une liste d'arêtes.

  Exemple:

        arête1 = Edge("E19", 50000, "Bruxelles, "Anvers")
        arête2 = Edge("E40", 35000, "Bruxelles", "Gand")
        arête3 = Edge("E17", 60000, "Anvers", "Gand")
        arêtes = Vector{Edge{Int}}[arête1,arête2,arête3]
        adjacency(arêtes) = 
            ("Bruxelles" => [arête1, arête2], "Gand" => [arête2, arête3], "Anvers" => [arête1, arête3]).
"""
function adjacency(edges::Vector{Edge{U}}) where {U}
  adjacency = Dict{String,Vector{Edge{U}}}()
  for edge in edges
    add_adjacency!(adjacency, edge)
  end
  return adjacency
end

"""
	add_adjacency!(adjacency::Dict{String, Vector{Edge{U}}}, edge::Edge{U})

Ajoute une arête à un dictionnaire d'adjacence.
"""
function add_adjacency!(adjacency::Dict{String,Vector{Edge{U}}}, edge::Edge{U}) where {U}
  if haskey(adjacency, edge.node1_id)
    push!(adjacency[edge.node1_id], edge)
  else
    adjacency[edge.node1_id] = [edge]
  end
  if haskey(adjacency, edge.node2_id)
    push!(adjacency[edge.node2_id], edge)
  else
    adjacency[edge.node2_id] = [edge]
  end
end