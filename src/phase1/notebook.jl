### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 59581644-75f1-11ef-19ac-135b9f1fda05
md"""
Maxence Gollier, Sacha Benarroch-Lelong

MTH6412B, Polytechnique Montréal, Automne 2024
## Projet voyageur de commerce - Phase 1

Notre code est disponible sur [ce dépôt GitHub](https://github.com/MaxenceGollier/mth6412b-starter-code.git).

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
"""
	name(n::Any)

Renvoie le nom de l'objet passé en argument."""
name(n::Any) = nothing

# ╔═╡ a834d3a7-ac95-4387-9814-34b95996fcdf
md"""
Cette méthode n'est volontairement pas documentée pour coller aux bonnes pratiques préconisées par la section [*Functions and methods*](https://docs.julialang.org/en/v1/manual/documentation/#Functions-and-Methods) de la documentation de Julia : lors d'une surcharge, seule la méthode la plus générique (ici, celle du dessus) doit être documentée.
"""

# ╔═╡ bd70525e-847a-4a4e-8b48-b15f730756a0
name(node::AbstractNode) = node.name

# ╔═╡ 06840074-6cd6-47b5-9c3d-3094ea447b46
"""
	data(node::AbstractNode)

Renvoie les données contenues dans le noeud."""
data(node::AbstractNode) = node.data

# ╔═╡ 55d1c970-5022-4e10-81a4-394db3b0ed51
md"""
Pour des raisons de compatibilité avec l'approche réactive des carnets Pluton, l'écriture de toutes les méthodes `show` est différée à la fin de ce rapport.
"""

# ╔═╡ 760fafda-c203-4e5c-af67-168e8ce4883a
md"""
### Arêtes d'un graphe et dictionnaire d'adjacence

#### Arêtes

Pour des raisons d'efficacité de l'implémentation (qui seront rendues plus claires dans la section sur la structure de graphe), on choisit de découpler les objets `Node` des objets `Edge`. Les noeuds que lie une arête sont donc simplement identifiés par leurs noms. L'hypothèse est faite que dans un graphe, le nom de chaque noeud est unique.

Rappelons que nous travaillons avec des graphes non orientés, ainsi la numérotation de ces sommets au sein d'un noeud est arbitraire. Pour $i,j\in E$, les arêtes $(i,j)$ et $(j,i)\in V$ sont donc représentées par un seul objet `Edge`.

La définition du type `Edge` est accompagnée de deux constructeurs de convenance.
"""

# ╔═╡ 82b10ecd-e637-4b39-9096-073d62d6356d
"""Type abstrait dont d'autres types d'arêtes dériveront."""
abstract type AbstractEdge{U} end

# ╔═╡ 1258b579-6f2c-4d2e-9f66-5bc4667feb79
begin
	
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
	function Edge(node1_id::T, node2_id::T, weight::U) where{T <: Number, U}
	  Edge(string(node1_id)*"-"*string(node2_id), weight, string(node1_id), string(node2_id))
	end
	
	"""Construit une arête à partir d'un poids et de deux identifiants de noeud."""
	function Edge(node1_id::String, node2_id::String, weight::U) where{U}
	    Edge(node1.name*"-"*node2.name, weight, node1_id, node2_id)
	end
end

# ╔═╡ 2adedda1-b2b8-4aea-9759-1cc3742c5297
md"""
#### Dictionnaire d'adjacence

Le dictionnaire d'adjacence est la structure intermédiaire permettant de regrouper les liens créés par les arêtes. Ici encore, seuls les noms des noeuds sont impliqués, pas les objets `Node`.

Un dictionnaire d'adjacence regroupe tous les liens existant au sein d'un graphe, de façon que la consultation de l'élément `node_name` du dictionnaire fournit les voisins du noeud de nom `node_name`, avec la donnée associée à l'arête les reliant. Sous forme schématique :

```julia
adjacency[node_name] = [(name_neighbor_1, data_edge_1), (name_neighbor_2, data_edge_2)]
```
"""

# ╔═╡ 5e58e28c-8815-45ea-8701-31c7acf6a50f
"""
	add_adjacency!(adjacency::Dict{String, Vector{Tuple{String, U}}}, edge::Edge{U})

Ajoute une arête à un dictionnaire d'adjacence.
"""
function add_adjacency!(adjacency::Dict{String, Vector{Tuple{String, U}}}, edge::Edge{U}) where{U}
  if haskey(adjacency, edge.node1_id)
    push!(adjacency[edge.node1_id], (edge.node2_id, edge.data))
  else
    adjacency[edge.node1_id] = Tuple{String, U}[(edge.node2_id, edge.data)]
  end
  if haskey(adjacency, edge.node2_id)
    push!(adjacency[edge.node2_id], (edge.node1_id, edge.data))
  else
    adjacency[edge.node2_id] = Tuple{String, U}[(edge.node1_id, edge.data)]
  end
end

# ╔═╡ 408c1f9a-01e1-404e-b687-6699efa87591
"""
	adjacency(edges::Vector{Edge{U}})

Construit un dictionnaire d'adjacence à partir d'une liste d'arêtes.

  Exemple:

        arête1 = Edge("E19", 50000, "Bruxelles, "Anvers")
        arête2 = Edge("E40", 35000, "Bruxelles", "Gand")
        arête3 = Edge("E17", 60000, "Anvers", "Gand")
        arêtes = Vector{Edge{Int}}[arête1,arête2,arête3]
        adjacency(arêtes) = 
            ("Bruxelles" => [("Anvers", 50000), ("Gand", 35000)], "Gand" => [("Bruxelles", 35000), ("Anvers", 60000)], "Anvers" => [("Bruxelles", 50000), ("Gand", 60000)]).
"""
function adjacency(edges::Vector{Edge{U}}) where{U}
  adjacency = Dict{String, Vector{Tuple{String, U}}}()
  for edge in edges
    add_adjacency!(adjacency,edge)
  end
  return adjacency
end

# ╔═╡ a99c09be-af38-449d-9e5a-fd6b533ffa38
md"""
### Structure de graphe

Les choix d'implémentation faits prendront leur sens ici.

- Noeuds et arêtes sont stockés en tant que dictionnaires. Ainsi, la requête `graph[node_name]` permet d'accéder à l'objet `Node` d'identifiant `node_name` du graphe, et le schéma est le même pour les arêtes.
- Le dictionnaire d'adjacence décrit précédemment permet d'accéder facilement aux voisins d'un noeud.

**Attention !**
> - Tous les noeuds doivent avoir des données de même type (ici, `T`).
> - Toutes les arêtes doivent également avoir des données du même type (ici, `U`).
> - Ces deux types ne sont pas forcément les mêmes.
> - Les noms des noeuds et des arêtes doivent être uniques.
"""

# ╔═╡ ac3882cc-9b22-411b-b274-b77485414787
"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T, U} end

# ╔═╡ 6a26e733-bd81-4828-bcc8-b5ea61bf805c
begin
	"""Type representant un graphe comme un ensemble de noeuds et d'arêtes.
	
	Exemple :
	
	    node1 = Node("Joe", 3.14)
	    node2 = Node("Steve", exp(1))
	    node3 = Node("Jill", 4.12)
	    edge1 = Edge("Joe-Steve", 2, "Joe", "Steve")
	    edge1 = Edge("Joe-Jill", -5, "Joe", "Jill")
	    G = Graph("Ick", [node1, node2, node3], [edge1,edge2])
	"""
	mutable struct Graph{T,U} <: AbstractGraph{T,U}
	  name::String
	  nodes::Dict{String,Node{T}}
	  edges::Dict{String,Edge{U}}
	  adjacency::Dict{String,Vector{Tuple{String,U}}}
	end

	"""Construit un graphe à partir d'une liste de noeud et d'arêtes"""
	function Graph(name::String, nodes::Vector{Node{T}}, edges::Vector{Edge{U}}) where {T,U}
	  return Graph(name, Dict(node.name => node for node in nodes), Dict(edge.name => edge for edge in edges), adjacency(edges))
	end
end

# ╔═╡ ea014785-2d0b-4d47-aa6e-d26030d5d3ba
md"""
Ajout de noeuds ou d'arêtes à un objet `Graph`.
"""

# ╔═╡ da4c2c05-be72-4253-bfe5-857290e0c452
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

# ╔═╡ 3ed82e4a-5b3e-4ee5-a1e4-81f179ffcddd
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
  graph
end

# ╔═╡ eb767c92-b74a-43de-95ae-0cf9383cbcd6
"""
	add_edge(graph::Graph{T,U}, node_1::Node{T}, node_2::Node{T}, weight::U)

Fonction de complaisance. Crée dynamiquememnt une arête à partir des noeuds `node_1` et `node_2`. L'information est vue comme un poids : l'argument `weight` doit être un nombre.
"""
function add_edge(graph::Graph{T,U}, node_1::Node{T}, node_2::Node{T}, weight::U) where {T,U <: Number}
  edge = Edge(node_1.name, node_2.name, weight)
  add_edge!(graph, edge)
  graph
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
nodes(graph::AbstractGraph) = keys(graph.nodes)

# ╔═╡ c858cc74-7721-49a8-8fb1-1a4d45c69c69
"""
	edges(graph::AbstractGraph)

Renvoie la liste des arêtes d'un graphe.
"""
edges(graph::AbstractGraph) = keys(graph.edges)

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
	function show(edge::AbstractEdge{U}) where {U}
	  println("Edge ", edge.name, ", linking ", edge.node1.name, " with ", edge.node2.name, ", data: ", edge.data)
	end

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
	
end

# ╔═╡ 3e302ff4-7cc1-4984-8e1e-f511519b7fba
md"""
### Lecture d'un fichier `.tsp`

Afin de ne pas surcharger ce rapport, on ne retranscrira pas ici le code servant à la lecture d'un fichier `.tsp` puisque la version fournie dans le code de départ est quasiment suffisante au regard des structures de données et des constructeurs implémentés jusqu'ici.

La seule modification majeure apportée au code proposée se situe dans la méthode `read_edges` et remplace la création d'un tuple entre les noeuds par l'instanciation d'un objet `Edge` en ajoutant la lecture des poids dans les fichiers `.tsp`. Les arêtes sont ainsi rapidement créées grâce au constructeur de convenance présenté plus tôt.
"""

# ╔═╡ 213670d7-c028-4d6a-8f5f-bc51c830d248
md"""
### Tests unitaires

La stabilité de nos structures de données peut être évaluée en exécutant les tests unitaires inclus dans l'environnement Julia `STSP` proposé dans le dossier `phase1` de notre dépôt GitHub.
"""

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
# ╟─2adedda1-b2b8-4aea-9759-1cc3742c5297
# ╠═408c1f9a-01e1-404e-b687-6699efa87591
# ╠═5e58e28c-8815-45ea-8701-31c7acf6a50f
# ╟─a99c09be-af38-449d-9e5a-fd6b533ffa38
# ╠═ac3882cc-9b22-411b-b274-b77485414787
# ╠═6a26e733-bd81-4828-bcc8-b5ea61bf805c
# ╟─ea014785-2d0b-4d47-aa6e-d26030d5d3ba
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
# ╟─3e302ff4-7cc1-4984-8e1e-f511519b7fba
# ╟─213670d7-c028-4d6a-8f5f-bc51c830d248
