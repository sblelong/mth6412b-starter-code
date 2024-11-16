export Graph, add_node!, add_edge!, add_edge, name, nodes, edges, nb_edges, nb_nodes, adjacency, show

"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T,U} end

"""Type representant un graphe comme un ensemble de noeuds et d'arêtes.

Exemple :

    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    edge1 = Edge("Joe-Steve", 2, "Joe", "Steve")
    edge1 = Edge("Joe-Jill", -5, "Joe", "Jill")
    G = Graph("Ick", [node1, node2, node3], [edge1,edge2])

De façon interne, les noeuds et les arêtes sont stockés en tant que dictionnaire. Ceci permet de retrouver des noeuds/arêtes rapidement à partir de leurs identifiants.
De plus, l'adjacence est stockée en tant que dictionnaire ce qui permet facilement d'accéder aux voisins d'un noeud.
Attention, tous les noeuds doivent avoir des données de même type. Toutes les arêtes doivent également avoir des données du même type mais pas nécessairement le même type que celui des noeuds.
De plus, les noms des noeuds et des arêtes doivent être uniques.
"""
mutable struct Graph{T,U} <: AbstractGraph{T,U}
  name::String
  nodes::Dict{String,Node{T}}
  edges::Dict{String,Edge{U}}
  adjacency::Dict{String,Vector{Edge{U}}}
  cost::Dict{String, Dict{String, U}}
end

"""
		Graph(name::String, nodes::Vector{Node{T}}, edges::Vector{Edge{U}})
	
	Construit un graphe à partir d'une liste de noeud et d'arêtes.
	"""
function Graph(name::String, nodes::Vector{Node{T}}, edges::Vector{Edge{U}}) where {T,U}
  return Graph(name, Dict(node.name => node for node in nodes), Dict(edge.name => edge for edge in edges), adjacency(edges), cost(edges))
end

"""
	add_node!(graph::Graph{T,U}, node::Node{T})

Ajoute un noeud au graphe. Si l'identifiant du noeud existe déjà dans le graphe, une erreur est renvoyée.
"""
function add_node!(graph::Graph{T,U}, node::Node{T}) where {T,U}
  if haskey(graph.nodes, node.name)
    error("Node name $(node.name) already exists in graph, are you sure your identifier is unique?")
  end
  merge!(graph.nodes, Dict(node.name => node))
  graph
end

"""
	add_edge!(graph::Graph{T,U}, edge::Edge{T})

Ajoute une arête au graphe. Met également à jour le dictionnaire d'adjacence du graphe. Si l'identifiant de l'arête existe déjà dans le graphe, une erreur est renvoyée. Si les identifiants de noeuds correspondant à l'arête n'existent pas dans le graphe, une erreur est renvoyée.
"""
function add_edge!(graph::Graph{T,U}, edge::Edge{T}) where {T,U}
  if haskey(graph.edges, edge.name)
    error("Edge name $(edge.name) already exists in graph, are you sure your identifier is unique ?")
  end
  if !haskey(graph.nodes, edge.node1_id)
    error("Trying to add edges with nonexisting node $(edge.node1_id), please add node first.")
  end
  if !haskey(graph.nodes, edge.node2_id)
    error("Trying to add edges with nonexisting node $(edge.node2_id), please add node first.")
  end
  merge!(graph.edges, Dict(edge.name => edge))
  add_adjacency!(graph.adjacency, edge)
  add_cost!(graph.cost, edge)
  graph
end

"""
	add_edge(graph::Graph{T,U}, node_1::Node{T}, node_2::Node{T}, weight::U)

Fonction de commodité. Crée dynamiquememnt une arête à partir des noeuds `node_1` et `node_2`. L'information est vue comme un poids : l'argument `weight` doit être un nombre.
"""
function add_edge(graph::Graph{T,U}, node_1::Node{T}, node_2::Node{T}, weight::U) where {T,U<:Number}
  edge = Edge(node_1.name, node_2.name, weight)
  add_edge!(graph, edge)
  graph
end

# on présume que tous les graphes dérivant d'AbstractGraph
# posséderont des champs `name`, `nodes` et `edges` 

name(graph::AbstractGraph) = graph.name

"""
	nodes(graph::AbstractGraph)

Renvoie la liste des noeuds du graphe.
"""
nodes(graph::AbstractGraph) = keys(graph.nodes)

"""
	edges(graph::AbstractGraph)

Renvoie la liste des arêtes d'un graphe.
"""
edges(graph::AbstractGraph) = keys(graph.edges)

"""
	nb_nodes(graph::AbstractGraph)

Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

"""
	nb_edges(graph::AbstractGraph)
Renvoie le nombre d'arêtes d'un graphe.
"""
nb_edges(graph::AbstractGraph) = length(graph.edges)

"""
		show(graph::Graph)
		
	Affiche un graphe."""
function show(graph::Graph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")
  for node in nodes(graph)
    show(node)
  end

  for edge in edges(graph)
    show(edge)
  end
end
