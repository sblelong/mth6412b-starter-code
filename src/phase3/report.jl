### A Pluto.jl notebook ###
# v0.20.0

using Markdown
using InteractiveUtils

# ╔═╡ b04be6ac-9ab6-47bd-9c78-e1840e1b5c0c
begin
	import Pkg
	Pkg.activate(Base.current_project())
	Pkg.instantiate()
end

# ╔═╡ 4fcc55e4-8a7e-11ef-3808-dbc5993500b2
md"""
Maxence Gollier, Sacha Benarroch-Lelong

MTH6412B, Polytechnique Montréal, Automne 2024
## Projet voyageur de commerce - Phase 3

Notre code est disponible sur [ce dépôt GitHub](https://github.com/MaxenceGollier/mth6412b-starter-code.git). Il est organisé selon une structure de projet Julia. L'environnement associé est nommé `STSP`.

La troisième phase est consacrée à l'implémentation d'heuristiques pour travailler avec les arbres de recouvrement minimaux, et à l'algorithme de Prim pour la génération de tels arbres.
"""

# ╔═╡ fabceac0-b7de-4c81-a79c-a7f00d332069
md"""
#### Activation de l'environnement

Ceci évitera simplement de réimporter les structures définies précédemment.
"""

# ╔═╡ 320c6b8a-ff32-46c8-a9d6-a6f370db8805
md"""
## Heuristiques d'accélération
"""

# ╔═╡ 61e2e580-6719-4b62-9787-c7cfc12919d8
md"""
### Union par le rang

#### Inégalités sur le rang

On commencera par prouver les inégalités sur le rang d'un noeud mentionnées dans le laboratoire. Dans un graphe $G=(S,Q)$, on notera $\mathrm{rang}(s)$ le rang du noeud $s\in S$.

**Proposition 1 :** $\forall s\in S, \mathrm{rang}(s)\leq\vert S\vert -1$.

*Démonstration*. Cette propriété est immédiate :
- Les rangs des noeuds sont initialisés à $0$;
- Le rang d'un noeud est incrémenté de $1$ dès lors qu'il est la racine d'une composante connexe et que celle-ci est réunie avec une autre.
Or au début de toute procédure, il y a au plus $\vert S\vert$ composantes connexes dans le graphe (une par noeud). L'opération d'union a donc lieu au plus $\vert S\vert -1$ fois. Il est donc impossible que le rang d'un noeud dépasse cette valeur (puisqu'il n'augmente que de $1$ à chaque fois).

**Proposition 2 :** En réalité, $\forall s\in S, \mathrm{rang}(s)\leq \lfloor \log_2(\vert S\vert)\rfloor$.

*Démonstration*. Supposons que pour $\hat{s}\in S$, on ait $\mathrm{rang}(s)=\lfloor \log_2(\vert S\vert)\rfloor +1$.
Remarquons qu'à une itération quelconque, la présence d'un noeud $s$ de rang $m>1$  implique que :
-  $m-1$ réunions ont été effectuées retournant des arbres avec $s$ pour racine;
- au moins $m-1$ autres réunions ont été effectuées sur des composantes connexes n'impliquant pas $s$, pour obtenir un noeud $s'$ de rang $m-1$. Et fusionner les arbres de racines respectives $s$ et $s'$.
Soit $\{i_m\}_{m\in\mathbb{N}}$ la suite associant à $m$ le nombre minimal d'itérations nécessaires à obtenir un noeud de rang $m$. Les observations précédentes montrent que $i_n=2i_{n-1}$, or $i_1=1$ et donc $i_n=2^n$.

En appliquant ce principe à $\hat{s}$, son existence présuppose que $2^{\lfloor \log_2(\vert S\vert)\rfloor +1}>\vert S\vert$ réunions ont été effectuées. Or l'algorithme étant initialisé avec exactement $\vert S\vert$ composantes disjointes, ceci est impossible.
"""

# ╔═╡ 68e37776-f7f8-479f-abdf-a66984f368ad
md"""
#### Implémentation

Dans la phase précédente, l'union de composantes connexes que nous avions implémentée était basée sur un attribut de "taille" de chaque composante. Les tailles étaient additionnées à chaque réunion. L'union par le rang est une variante de cette méthode, nous avons donc opté pour une implémentation qui nous permet de continuer à travailler avec la même structure, quel que soit le mode d'union choisi.

La structure `Tree` et son constructeur changent ainsi pour devenir :

L'implémentation implique donc 2 changements :
- Classe `Tree` : size et rank deviennent des arguments optionnels. Le constructeur s'adapte en conséquence : on doit pouvoir préciser si l'on veut initialiser la taille ou le rang.
- Dans ce cas, il faut s'assurer que l'on n'implémente plus directement la compression des chemins : le parent doit être le parent direct et non la racine de l'arbre.
- `merge!(::Forest, ::String, ::String)` implémente l'union par le rang (quasi déjà tout fait). Vérifier que le parent est bien le parent direct et pas la racine de l'arbre qui devient parent.
- Vérifier que tout ça n'empêche pas Kruskal de fonctionner.
- Mettre des tests unitaires.
"""

# ╔═╡ 124f8575-209e-41e4-a123-4368dc180012
begin
	import STSP.Tree

	"""
		Tree(parent_id, value; mode)
	
	Initialise un arbre à partir de l'identifiant de sa racine et d'une valeur de taille et de rang (option choisie par l'argumment `mode`).
	
	# Arguments
	- `parent_id` (`String`): l'identifiant du noeud constituant la racine de l'arbre
	- `value` (`Int64`): la valeur numérique de la taille ou du rang
	- `mode` (`String="size"`): ("size" ou "rank"). L'attribut qui doit être initialisé à la valeur `value` (la taille ou le rang).
	"""
	function Tree(parent_id::String, value::Int64; mode::String="size")
	  mode in ["size", "rank"] || error("When initializing a Tree, the `mode` argument should be 'size' or 'rank'.")
	  mode == "size" ? Tree(parent_id, String[], value, nothing) : Tree(parent_id, String[], nothing, value)
end
end

# ╔═╡ 70a06fc9-2be4-418a-8f50-3454b1035579
md"""
Et l'initialisation d'une forêt change en conséquence :
"""

# ╔═╡ a8d150d0-db4e-4e4f-bcfe-7bb8e896df4c
begin
	import STSP.Graph
	import STSP.Forest
	
	"""
		Forest(G; mode)
	
	Initialise une forêt de composantes connexes à partir d'un graphe. Un arbre de taille 1 ou de rang 0 est créé par noeud du graphe. Cette fonction est conçue pour servir à l'initialisation de l'algorithme de Kruskal.
	
	# Arguments
	- `G` (`Graph`): le graphe à partir duquel construire une forêt de composantes connexes
	- `mode` (`String="size"`) : (`"size"` ou `"rank"`). L'attribut à initialiser dans chaque arbre créé
	"""
	function Forest(G::Graph{T,U}; mode::String="size") where {T,U}
	  trees = Dict{String,Tree}()
	  mode in ["size", "rank"] || error("When initializing a Forest, the `mode` argument should be 'size' or 'rank'.")
	  for (node_id, node) in G.nodes
	    trees[node_id] = mode == "size" ? Tree(node_id, 1) : Tree(node_id, 0, mode="rank")
	  end
	  return Forest(trees, length(G.nodes))
	end

end

# ╔═╡ 5e020c44-1f37-453e-b8e6-7da27643479f
begin
	using Plots
	function plot_graph(nodes, edges, label_type::String="number")
	  fig = plot(legend=false)
	
	  # Preprocessing des arêtes
	  processed_edges = Vector{Int64}[]
	  for k in 1:length(nodes)
	    edge_list = []
	    push!(processed_edges, edge_list)
	  end
	  for edge in edges
		  if label_type == "number"
	    	push!(processed_edges[parse(Int64, edge.node1_id)], parse(Int64, edge.node2_id))
		  elseif label_type == "alph"
			  push!(processed_edges[Int64(edge.node1_id[1])-96], Int64(edge.node2_id[1])-96)
		  else
			  error("Label format $label_type is unknown.")
		  end
	  end
	
	  # edge positions
	  for k = 1:length(edges)
	    for j in processed_edges[k]
	      plot!([nodes[k].data[1], nodes[j].data[1]], [nodes[k].data[2], nodes[j].data[2]],
	        linewidth=1.5, alpha=0.75, color=:lightgray)
	    end
	  end
	
	  # node positions
	  xys = values(nodes)
	  x = [xy.data[1] for xy in xys]
	  y = [xy.data[2] for xy in xys]
	  scatter!(x, y)
	
	  fig
	end
	function plot_graph(graph::Graph, label_type::String="number")
	  plot_graph(collect(values(graph.nodes)), collect(values(graph.edges)), label_type)
	end
end

# ╔═╡ d186aafe-c30b-43d9-9e5d-d9b6153ce439
md"""
On peut grâce à cela ajouter l'union par le rang à la méthode `merge!` qui avait été implémentée dans la phase précédente. De même, celle-ci prend maintenant un argument optionnel `mode` qui permet de travailler soit avec la taille, soit avec le rang.
"""

# ╔═╡ ebbf6169-45c7-4639-b36a-d16a718cfdf4
begin
	import Base.merge!;
	
	"""
		merge!(forest, root_id1, root_id2; mode)
	
	Fonction permettant de fusionner deux arbres à partir de deux identifiants qui ont la propriété d'être des "racines". La fusion s'opère en redéfinissant le parent d'une "racine" par l'autre "racine".
	
	Pour choisir quelle racine prend l'autre racine comme enfant, 2 possibilités sont proposées.
	
	### [Union par la taille](https://en.wikipedia.org/wiki/Disjoint-set_data_structure#Union_by_size)
	La taille des arbres associés est comparée ; l'arbre de plus grande taille englobe l'autre. Cela nécessite que les attributs `size` des arbres de la forêt ne soient pas nuls.
	
	### Union par le rang
	Les rangs sont comparés et incrémentés selon la politique classique d'union par le rang.
	
	# Arguments
	- `forest` (`Forest`): forêt dans laquelle se trouvent les 2 arbres à fusionner
	- `root_id1` (`String`): identifiant de la racine du premier arbre participant à la fusion
	- `root_id2` (`String`): identifiant de la racine du second arbre participant à la fusion
	- `mode` (`String="size"`): (`"size"` ou `"rank"`). Indique le critère retenu pour l'union.
	
	# Type de retour
	Aucun : fonction *in-place*.
	"""
	function merge!(forest::Forest, root_id1::String, root_id2::String; mode::String="size")
	  trees = forest.trees
	
	  if mode == "size"
	    if trees[root_id1].size > trees[root_id2].size
	      trees[root_id2].parent_id = root_id1
	      trees[root_id1].size = trees[root_id1].size + trees[root_id2].size
	    else
	      trees[root_id1].parent_id = root_id2
	      trees[root_id2].size = trees[root_id2].size + trees[root_id1].size
	    end
	  elseif mode == "rank"
	    new_root = trees[root_id1].rank > trees[root_id2].rank ? root_id1 : root_id2
	    new_child = trees[root_id1].rank > trees[root_id2].rank ? root_id2 : root_id1
	
	    # Si les rangs sont égaux, c'est la seconde qui devient parent de la première et son rang augmente de 1.
	    if trees[root_id1].rank == trees[root_id2].rank
	      trees[new_root].rank += 1
	    end
	    trees[new_child].parent_id = new_root
	  else
	    error("When performing merge on connected components, the `mode` argument should be 'size' or 'rank'.")
	  end
	
	end
end

# ╔═╡ 72386634-0792-41bb-a212-c95e2031517b
md"""
La procédure de Kruskal est adaptée à cette nouvelle architecture en lui ajoutant aussi l'argument optionnel `mode` permettant de travailler avec le rang. L'initialisation de la forêt et les appels à `merge!` sont adaptés en conséquence.

L'algorithme de Kruskal est toujours fonctionnel avec ce nouveau mode d'union, comme en témoigne l'exemple donné en cours :
"""

# ╔═╡ 5af265e7-b701-4d09-9854-e20f41717bfa
begin

	import STSP.Node, STSP.Edge, STSP.find
	
	"""
		kruskal(G; mode)
	
	Implémentation de l'algorithme de Kruskal pour identifier un arbre de recouvrement minimal d'un graphe. Renvoie un tuple contenant le coût et une liste des arêtes formant l'arbre de poids minimal. Si le graphe n'est pas connexe, une erreur est renvoyée.
	
	# Arguments
	- `G` (`Graph`): le graphe dans lequel il faut identifier un arbre de recouvrement minimal
	- `mode` (`String="size"`): (`"size"` ou `"rank"`). Précise le mode d'union entre les composantes connexes qui doit être utilisé.
	
	# Type de retour
	`Float64`, `Vector{Edge}`
	
	# Exemples
	```julia-repl
	julia> kruskal(graph, mode="rank")
	```
	"""
	function kruskal(G::Graph{T,U}; mode::String="size") where {T,U}
	
	  ## Construct the initial forest
	  F = Forest(G; mode=mode)
	  cost = U(0)
	  edges = Edge{U}[]
	
	  ## Order the edges
	  sorted = sort(collect(G.edges), by=x -> x[2].data)
	
	  k = 1
	  while F.num_roots > 1 && k ≤ length(sorted)
	    edge = sorted[k][2]
	
	    node1_id = edge.node1_id
	    node2_id = edge.node2_id

	    root_node1 = find(F, node1_id)
	    root_node2 = find(F, node2_id)
	
	    if root_node1 ≠ root_node2 # L'arête n'ajoute pas de cycle.
	      F.num_roots = F.num_roots - 1
	      cost = cost + edge.data
	      merge!(F, root_node1, root_node2; mode=mode)
	      push!(edges, edge)
	    end
	
	    k = k + 1
	  end
	
	  # Toutes les arêtes ont été explorées mais il reste deux composantes connexes ne pouvant pas être fusionnées.
	  if k > length(sorted)
	    error("Kruskal: Graph is not connected.")
	  end
	  return cost, edges
	end

	nodes = [
		Node("a", [-2, 0]),
		Node("b", [-1, 1]),
		Node("c", [0, 1]),
		Node("d", [1, 1]),
		Node("e", [2, 0]),
		Node("f", [1, -1]),
		Node("g", [0, -1]),
		Node("h", [-1, -1]),
		Node("i", [-1, 0])
	]

	edges = [
		Edge("a", "b", 4),
		Edge("a", "h", 8),
		Edge("b", "c", 8),
		Edge("b", "h", 11),
		Edge("c", "d", 7),
		Edge("c", "i", 2),
		Edge("c", "f", 4),
		Edge("d", "e", 9),
		Edge("d", "f", 14),
		Edge("e", "f", 10),
		Edge("f", "g", 2),
		Edge("g", "i", 6),
		Edge("g", "h", 1),
		Edge("h", "i", 7)
	]

	G = Graph("KruskalLectureNotesTest", nodes, edges)
	
	cost, edges = kruskal(G, mode="rank")

	kruskal_graph = Graph("Example after Kruskal", nodes, edges)
end

# ╔═╡ 1bde19e5-1a37-4abc-a981-a295a98ba96f
plot_graph(kruskal_graph, "alph")

# ╔═╡ 0d1e38db-304c-4ef2-80b1-ce41fb9ac106
md"""
## Algorithme de Prim

L'algorithme de Prim pour la construction d'arbres de recouvrement minimaux est faite à travers une file de priorité. Son test sur les notes de cours donne :
"""

# ╔═╡ 2437bfa4-5b4a-4f75-9027-010c69a50bfc
begin
	import STSP.prim
	cost_prim, edges_prim = prim(G)
	prim_graph = Graph("Example after Prim", collect(values(G.nodes)), edges_prim)
	plot_graph(prim_graph, "alph")
end

# ╔═╡ 6de4b25f-60cd-43b7-ab99-619c3f50525d
md"""
### Tests sur quelques instances de TSP symétriques
"""

# ╔═╡ 94fe92ff-270d-4b96-884b-400d46ee39de
md"""
On affiche à chaque fois les coûts des arbres minimaux générés par les méthodes de Kruskal et de Prim, pour s'assurer qu'ils sont identiques. Les tracés sont ceux des arbres obtenus par Prim.
"""

# ╔═╡ a71c9711-de36-4357-970d-949164845dd7
import STSP.read_stsp

# ╔═╡ 1aa6ee07-a8a0-4efa-b84b-104a57b7d07d
md"""
Instance `dantzig42.tsp`
"""

# ╔═╡ f86a170e-b8ac-4bd9-9725-2d934b682d67
begin
	d42 = read_stsp("../../instances/stsp/dantzig42.tsp")
	d42_cost_kruskal, d42_edges_kruskal = kruskal(d42)
	d42_cost_prim, d42_edges_prim = prim(d42)
	d42_prim = Graph("Prim on dantzig42", collect(values(d42.nodes)), d42_edges_prim)
	println("Coût de l'arbre généré par Kruskal : $d42_cost_kruskal. Coût de l'arbre généré par Prim : $d42_cost_prim")
end

# ╔═╡ 6692f11f-c25f-457f-bedc-048f92fd22e2
plot_graph(d42_prim)

# ╔═╡ 6441584e-2e84-4ad6-a772-38c13363068e
md"""
Instance `gr120`
"""

# ╔═╡ 66db58b7-7f70-4ddb-a533-318e73a7729b
begin
	gr120 = read_stsp("../../instances/stsp/gr120.tsp")
	gr120_cost_kruskal, gr120_edges_kruskal = kruskal(gr120)
	gr120_cost_prim, gr120_edges_prim = prim(gr120)
	gr120_prim = Graph("Prim on gr120", collect(values(gr120.nodes)), gr120_edges_prim)
	println("Coût de l'arbre généré par Kruskal : $gr120_cost_kruskal. Coût de l'arbre généré par Prim : $gr120_cost_prim")
end

# ╔═╡ 974f09b5-6505-4090-a663-4979aa11bee9
plot_graph(gr120_prim)

# ╔═╡ e6255e42-6d83-4d36-9130-7dc8129b1c14
md"""
## Tests unitaires

Des tests unitaires ont été implémentés tout au long du développement et sont intégrés au module `STSP` . Ces tests sont pour l'instant répartis en deux ensembles :
- `Lecture Notes Graph` : teste les fonctions nécessaires aux algorithmes de Kruskal et de Prim, ainsi que les algorithmes eux-mêmes, sur le graphe proposé dans les notes de cours, ou des sous-ensembles de ce graphe.
- `AccelerationHeuristics` : teste les fonctions utilisant les heuristiques d'accélération évoquées plus haut dans ce rapport, notamment l'algorithme de Kruskal avec union par le rang.
La commande suivante permet de vérifier que tous ces tests sont passés par les fonctions implémentées :
"""

# ╔═╡ 743b4b04-45e3-4411-a2ef-b10a5df07dfb
Pkg.test()

# ╔═╡ Cell order:
# ╟─4fcc55e4-8a7e-11ef-3808-dbc5993500b2
# ╟─fabceac0-b7de-4c81-a79c-a7f00d332069
# ╟─b04be6ac-9ab6-47bd-9c78-e1840e1b5c0c
# ╟─320c6b8a-ff32-46c8-a9d6-a6f370db8805
# ╟─61e2e580-6719-4b62-9787-c7cfc12919d8
# ╟─68e37776-f7f8-479f-abdf-a66984f368ad
# ╠═124f8575-209e-41e4-a123-4368dc180012
# ╟─70a06fc9-2be4-418a-8f50-3454b1035579
# ╟─a8d150d0-db4e-4e4f-bcfe-7bb8e896df4c
# ╟─d186aafe-c30b-43d9-9e5d-d9b6153ce439
# ╟─ebbf6169-45c7-4639-b36a-d16a718cfdf4
# ╟─72386634-0792-41bb-a212-c95e2031517b
# ╟─5af265e7-b701-4d09-9854-e20f41717bfa
# ╟─5e020c44-1f37-453e-b8e6-7da27643479f
# ╟─1bde19e5-1a37-4abc-a981-a295a98ba96f
# ╟─0d1e38db-304c-4ef2-80b1-ce41fb9ac106
# ╟─2437bfa4-5b4a-4f75-9027-010c69a50bfc
# ╟─6de4b25f-60cd-43b7-ab99-619c3f50525d
# ╟─94fe92ff-270d-4b96-884b-400d46ee39de
# ╠═a71c9711-de36-4357-970d-949164845dd7
# ╟─1aa6ee07-a8a0-4efa-b84b-104a57b7d07d
# ╟─f86a170e-b8ac-4bd9-9725-2d934b682d67
# ╟─6692f11f-c25f-457f-bedc-048f92fd22e2
# ╟─6441584e-2e84-4ad6-a772-38c13363068e
# ╟─66db58b7-7f70-4ddb-a533-318e73a7729b
# ╟─974f09b5-6505-4090-a663-4979aa11bee9
# ╟─e6255e42-6d83-4d36-9130-7dc8129b1c14
# ╠═743b4b04-45e3-4411-a2ef-b10a5df07dfb
