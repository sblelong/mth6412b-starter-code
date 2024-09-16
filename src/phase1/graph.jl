import Base.show

"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T, U} end

"""Type representant un graphe comme un ensemble de noeuds.

Exemple :

    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    G = Graph("Ick", [node1, node2, node3])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct Graph{T, U} <: AbstractGraph{T, U}
  name::String
  nodes::Vector{Node{T}}
  edges::Vector{Edge{T, U}}
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::Graph{T, U}, node::Node{T}) where {T, U}
  push!(graph.nodes, node)
  graph
end

function add_edge!(graph::Graph{T, U}, edge::Edge{T}) where {T, U}
  push!(graph.edges, edge)
  graph
end

function add_edge(graph::Graph{T, U}, node_1::Node{T}, node_2::Node{T}, weight::U) where {T, U}
  edge = Edge(node_1, node_2, weight)
  add_edge!(graph, edge)
end

# on présume que tous les graphes dérivant d'AbstractGraph
# posséderont des champs `name` et `nodes`.

"""Renvoie le nom du graphe."""
name(graph::AbstractGraph) = graph.name

"""Renvoie la liste des noeuds du graphe."""
nodes(graph::AbstractGraph) = graph.nodes

"""Renvoie la liste des arêtes d'un graphe."""
edges(graph::AbstractGraph) = graph.edges

"""Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

"""Renvoie le nombre d'arêtes d'un graphe."""
nb_edges(graph::AbstractGraph) = length(graph.edges)

"""Affiche un graphe"""
function show(graph::Graph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")
  for node in nodes(graph)
    show(node)
  end

  for edge in edges(graph)
    show(edge)
  end
end
