### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 59581644-75f1-11ef-19ac-135b9f1fda05
md"""
Maxence Gollier, Sacha Benarroch-Lelong

MTH6412B, Polytechnique Montréal, Automne 2024
## Projet voyageur de commerce - Phase 1

Cette première phase est dédiée à la conception de structures de données appropriées pour manipuler des graphes.

Adoptons d'emblée la notation $G=(V,E)$ pour désigner un graphe quelconque, avec $V$ l'ensemble de ses sommets et $E\subseteq V\times V$ l'ensemble de ses arêtes. Puisque nous travaillons avec des problèmes symétriques, nous considérerons des graphes non orientés, ainsi $\forall i,j\in V, i\neq j$ et $(i,j)\in E\implies (j,i)\in E$.

"""

# ╔═╡ dba7dfaf-294f-43c2-85bc-b5be213396da
md"""
### Noeuds d'un graphe

*Note : Dans toute la suite, on désignera par `T` ou `U` des types de données quelconques.*

On reprend ici l'implémentation fournie pour un noeud.
"""

# ╔═╡ ecc4f11d-43e1-48bc-99ea-2c152e50d072
"""Type abstrait dont d'autres types de noeuds dériveront."""
abstract type AbstractNode{T} end

# ╔═╡ 30b76bc3-b0e0-46eb-9d29-cef133660fda
"""Type représentant les noeuds d'un graphe.

Exemple:

        noeud = Node("James", [π, exp(1)])
        noeud = Node("Kirk", "guitar")
        noeud = Node("Lars", 2)

"""
mutable struct Node{T} <: AbstractNode{T}
  name::String
  data::T
end

# on présume que tous les noeuds dérivant d'AbstractNode
# posséderont des champs `name` et `data`.

# ╔═╡ b743915d-15f9-4a00-bee0-42c86c2bdaf0
"""Renvoie le nom de l'objet passé en argument."""
name(n::Any) = nothing

# ╔═╡ a834d3a7-ac95-4387-9814-34b95996fcdf
md"""
Cette méthode n'est volontairement pas documentée pour coller aux bonnes pratiques préconisées par la section [*Functions and methods*](https://docs.julialang.org/en/v1/manual/documentation/#Functions-and-Methods) de la documentation de Julia : lors d'une surcharge, seule la méthode la plus générique (ici, celle du dessus) doit être documentée.
"""

# ╔═╡ bd70525e-847a-4a4e-8b48-b15f730756a0
name(node::AbstractNode) = node.name

# ╔═╡ 06840074-6cd6-47b5-9c3d-3094ea447b46
"""Renvoie les données contenues dans le noeud."""
data(node::AbstractNode) = node.data

# ╔═╡ 55d1c970-5022-4e10-81a4-394db3b0ed51
md"""
Pour des raisons de compatibilité avec l'approche réactive des carnets Pluton, l'écriture de toutes les méthodes `show` est différée à la fin de ce rapport.
"""

# ╔═╡ 760fafda-c203-4e5c-af67-168e8ce4883a
md"""
### Arêtes d'un graphe

Une arête lie deux sommets. Rappelons que nous travaillons avec des graphes non orientés, ainsi la numérotation de ces sommets au sein d'un noeud est arbitraire. Pour $i,j\in E$, les arêtes $(i,j)$ et $(j,i)\in V$ sont donc représentées par un seul objet `Edge`.
"""

# ╔═╡ 82b10ecd-e637-4b39-9096-073d62d6356d
"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{T, U} end

# ╔═╡ 1258b579-6f2c-4d2e-9f66-5bc4667feb79
"""Type représentant les arêtes d'un graphe.
	
Exemple:

	edge1 = Edge("A35", 110, node1, node2)
	edge2 = Edge("Café", "Très cher", Node("Jean-Paul", [4, 5]), Node("Simone", [1,2]))
	edge3 = Edge(node1, node2, n -> 130/(0.05*n))
	
"""
mutable struct Edge{T, U} <: AbstractEdge{T, U}
	name::String
	data::U
	node1::AbstractNode{T}
	node2::AbstractNode{T}
	Edge(node1::Node{T}, node2::Node{T}, weight::U) where {T,U} = Edge(node1.name*"-"*node2.name, weight, node1, node2)
end

# ╔═╡ a99c09be-af38-449d-9e5a-fd6b533ffa38
md"""
### Structure de graphe

Avec ce qu'on vient de construire, on définit maintenant la structure de graphe. Cette structure est caractérisée par 2 types quelconques : `T` est celui des informations liées aux noeuds, `U` celui des informations liées aux arêtes.
"""

# ╔═╡ ac3882cc-9b22-411b-b274-b77485414787
"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T, U} end

# ╔═╡ 6a26e733-bd81-4828-bcc8-b5ea61bf805c
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

# ╔═╡ da4c2c05-be72-4253-bfe5-857290e0c452
"""
	add_node!(graph::Graph{T,U}, node::Node{T})

Ajoute un noeud au graphe.
"""
function add_node!(graph::Graph{T, U}, node::Node{T}) where {T, U}
  push!(graph.nodes, node)
  graph
end

# ╔═╡ 3ed82e4a-5b3e-4ee5-a1e4-81f179ffcddd
"""
	add_edge!(graph::Graph{T,U}, edge::Edge{T})

Ajoute une arête au graphe.
"""
function add_edge!(graph::Graph{T, U}, edge::Edge{T}) where {T, U}
  push!(graph.edges, edge)
  graph
end

# ╔═╡ eb767c92-b74a-43de-95ae-0cf9383cbcd6
"""
	add_edge(graph::Graph{T,U}, node_1::Node{T}, node_2::Node{T}, weight::U)

Fonction de complaisance. Crée dynamiquememnt une arête à partir des noeuds `node_1` et `node_2`. L'information est vue comme un poids : l'argument `weight` doit être un nombre.
"""
function add_edge(graph::Graph{T, U}, node_1::Node{T}, node_2::Node{T}, weight::U) where {T, U <: Number}
  edge = Edge(node_1, node_2, weight)
  add_edge!(graph, edge)
end

# ╔═╡ 6160b473-36aa-45ee-8dc3-9d932ca3dfa0
md"""
Pour la même raison que précédemment, cette méthode n'est volontairement pas documentée.
"""

# ╔═╡ 8dbd13cc-7fa8-4ac7-84c2-fd7056f0de7d
name(graph::AbstractGraph) = graph.name

# ╔═╡ a3f39a77-711a-4a13-a15a-f7acd456ca13
"""
	nodes(graph::AbstractGraph)

Renvoie la liste des noeuds du graphe.
"""
nodes(graph::AbstractGraph) = graph.nodes

# ╔═╡ c858cc74-7721-49a8-8fb1-1a4d45c69c69
"""
	edges(graph::AbstractGraph)

Renvoie la liste des arêtes d'un graphe.
"""
edges(graph::AbstractGraph) = graph.edges

# ╔═╡ e23eae4d-5c41-40df-8a0c-1d9e607a0229
"""
	nb_nodes(graph::AbstractGraph)

Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

# ╔═╡ e33610b0-b24f-4693-ae2a-3b2759931687
"""
	nb_edges(graph::AbstractGraph)
Renvoie le nombre d'arêtes d'un graphe.
"""
nb_edges(graph::AbstractGraph) = length(graph.edges)

# ╔═╡ 43b677ce-2788-4231-ad08-7da25af9b379
md"""
### Fonctions d'affichage
"""

# ╔═╡ 3e0138db-693d-4e5d-9f98-c7ffbb2379a8
begin
	import Base.show

	"""
		show(node::AbstractNode)
	
	Affiche un noeud.
	"""
	function show(node::AbstractNode)
	  println("Node ", name(node), ", data: ", data(node))
	end
	
	"""
		show(edge::AbstractEdge{T,U})

	Affiche une arête.
	"""
	function show(edge::AbstractEdge{T, U}) where {T, U}
	  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", weight: ", edge.data)
	end

	"""
		show(graph::AbstractGraph{T,U})

	Affiche un graphe.
	"""
	function show(graph::AbstractGraph{T,U}) where {T,U}
	  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and ", nb_edges(graph), " edges.")
	  for node in nodes(graph)
	    show(node)
	  end
	
	  for edge in edges(graph)
	    show(edge)
	  end
	end
end

# ╔═╡ 3e302ff4-7cc1-4984-8e1e-f511519b7fba


# ╔═╡ Cell order:
# ╟─59581644-75f1-11ef-19ac-135b9f1fda05
# ╟─dba7dfaf-294f-43c2-85bc-b5be213396da
# ╠═ecc4f11d-43e1-48bc-99ea-2c152e50d072
# ╠═30b76bc3-b0e0-46eb-9d29-cef133660fda
# ╠═b743915d-15f9-4a00-bee0-42c86c2bdaf0
# ╟─a834d3a7-ac95-4387-9814-34b95996fcdf
# ╠═bd70525e-847a-4a4e-8b48-b15f730756a0
# ╠═06840074-6cd6-47b5-9c3d-3094ea447b46
# ╟─55d1c970-5022-4e10-81a4-394db3b0ed51
# ╟─760fafda-c203-4e5c-af67-168e8ce4883a
# ╠═82b10ecd-e637-4b39-9096-073d62d6356d
# ╠═1258b579-6f2c-4d2e-9f66-5bc4667feb79
# ╟─a99c09be-af38-449d-9e5a-fd6b533ffa38
# ╠═ac3882cc-9b22-411b-b274-b77485414787
# ╠═6a26e733-bd81-4828-bcc8-b5ea61bf805c
# ╠═da4c2c05-be72-4253-bfe5-857290e0c452
# ╠═3ed82e4a-5b3e-4ee5-a1e4-81f179ffcddd
# ╠═eb767c92-b74a-43de-95ae-0cf9383cbcd6
# ╟─6160b473-36aa-45ee-8dc3-9d932ca3dfa0
# ╠═8dbd13cc-7fa8-4ac7-84c2-fd7056f0de7d
# ╠═a3f39a77-711a-4a13-a15a-f7acd456ca13
# ╠═c858cc74-7721-49a8-8fb1-1a4d45c69c69
# ╠═e23eae4d-5c41-40df-8a0c-1d9e607a0229
# ╠═e33610b0-b24f-4693-ae2a-3b2759931687
# ╟─43b677ce-2788-4231-ad08-7da25af9b379
# ╠═3e0138db-693d-4e5d-9f98-c7ffbb2379a8
# ╠═3e302ff4-7cc1-4984-8e1e-f511519b7fba
