### A Pluto.jl notebook ###
# v0.20.0

using Markdown
using InteractiveUtils

# ╔═╡ 3f521035-d2e9-4f82-8bdc-07dcd141c2cc
begin
	using Pkg
	Pkg.activate(Base.current_project())
	Pkg.instantiate()
	using Revise
	using STSP
end

# ╔═╡ 9cd6173c-da3f-4350-9e74-d281bab970f4
begin
	gr17 = read_stsp("../../instances/stsp/gr17.tsp")
	data_root_gr17_rsl = Dict("root_id"=>Vector{String}(), "cost"=>Vector{Float64}())
	for node_id in keys(gr17.nodes)
		cost, tour = rsl(gr17; root_method="choice", root_id=node_id)
		push!(data_root_gr17_rsl["root_id"], node_id)
		push!(data_root_gr17_rsl["cost"], cost)
	end

	using StatsPlots
	histogram(data_root_gr17_rsl["cost"], xlabel="Coût de la tournée", ylabel="Effectif", legend=nothing)
end

# ╔═╡ 7ff539cd-1d3f-4178-8d33-7cc6c3381d3d
begin
	using DataFrames
	gr17_rsl_df = DataFrame(data_root_gr17_rsl)
	boxplot(gr17_rsl_df[!,"cost"], ylabel="Coût de la tournée", legend=nothing)
end

# ╔═╡ a761fd2c-a29d-11ef-030c-5b7d55f07fe9
md"""
Maxence Gollier, Sacha Benarroch-Lelong

MTH6412B, Polytechnique Montréal, Automne 2024
## Projet voyageur de commerce - Phase 4

Notre code est disponible sur [ce dépôt GitHub](https://github.com/sblelong/mth6412b-starter-code). Il est organisé selon une structure de projet Julia. L'environnement associé est nommé `STSP`.

La quatrième phase est consacrée à l'implémentation d'algorithmes pour la confection de tournées minimales dans des graphes complets.
"""


# ╔═╡ 0f15ea4a-7a45-441c-9c63-1728de10b269
md"""
Activation de l'environnement
"""

# ╔═╡ 85cbc46c-b0c2-4957-ba4a-7f49693f5ba1
md"""
## Reproduction des résultats

Tous nos résultats (avec les hyperparamètres par défaut des algorithmes) peuvent être reproduits avec des instances différentes grâce aux fonctions du fichier `main.jl` présent sur notre dépôt Git. La fonction

```julia
test_phase4(instance::String; plot_results::Bool=false)
```

permet d'obtenir les tournées calculées par RSL et HK, une comparaison au coût optimal connu. La fonction doit être lancée depuis la racine du dépôt, et le nom de l'instance doit correspondre au nom du fichier dans le dossier `instances/stsp`. Par exemple :
```julia
test_phase4("dantzig42.tsp"; plot_results=true)
```
L'argument optionnel `plot_results` lancera un affichage de la tournée obtenue si passé à `true`.
"""

# ╔═╡ 6852139e-9169-4d90-a1ca-89a95de62da1
md"""
## Algorithme de Rosenkrantz, Stearns et Lewis

L'algorithme de Rosenkrantz, Stearns et Lewis (RSL) repose sur le calcul d'un arbre de recouvrement minimal du graphe. La signature de notre implémentation est comme suit :

```julia
rsl(G; root_method, root_id)
```

Elle permet de choisir la racine de l'arbre de recouvrement minimal, qui sera le point de départ de la tournée.
"""

# ╔═╡ 399519e2-ef90-45e9-ae07-87014655d698
md"""
### RSL avec l'algorithme de Prim

La seule implémentation que nous proposons ici repose sur l'algorithme de Prim pour le calcul de l'arbre minimal de recouvrement. En effet, puisque l'algorithme de Kruskal raisonne sur les arêtes plus que sur les noeuds, établir un préordre est bien plus difficile.

#### Premiers résultats

Nous montrons ici les résultats de notre implémentation de RSL sur quelques instances de TSP symétriques. Les racines des arbres de recouvrement (qui sont les points de départ des tournées0) sont déterminées aléatoirement.
"""

# ╔═╡ 2825b770-24ff-4222-89b2-96bf7e0a7fc1
md"""
`dantzig42`
"""

# ╔═╡ a00513aa-598a-475b-8403-f5e4d0dfcafa
begin
	d42 = read_stsp("../../instances/stsp/dantzig42.tsp")
	d42_rsl_cost, d42_tour = rsl(d42)
	d42_opt = 699
	println("Coût de la tournée proposée | ", d42_rsl_cost)
	println("RSL/opt (%) | ", d42_rsl_cost / d42_opt * 100)
end

# ╔═╡ def153fe-cca4-4110-977f-e153f0fb1f2b
plot_tour(d42, d42_tour)

# ╔═╡ f8f39406-facf-453e-99ee-6a72f960f67e
md"""
`bays29`
"""

# ╔═╡ 5c7c403b-5ad5-4826-acec-14ca5964538c
begin
	bays29 = read_stsp("../../instances/stsp/bays29.tsp")
	bays29_rsl_cost, bays29_tour = rsl(bays29)
	bays29_opt = 2020
	println("Coût de la tournée proposée | ", bays29_rsl_cost)
	println("RSL/opt (%) | ", bays29_rsl_cost / bays29_opt * 100)
end

# ╔═╡ 420e54b6-b0d4-4daa-a951-94e52c383e06
plot_tour(bays29, bays29_tour)

# ╔═╡ dad3ebc5-e2a3-41a3-b047-1bda5dd2246c
md"""
Posons comme constat préliminaire que la borne de 200% du coût optimal est respectée sur ces deux instances. Intéressons-nous maintenant aux autres instances proposées, et à l'effet de l'hyperparamètre principal de cette méthode : le choix de la racine.

#### Étude de l'effet du choix de la racine

Étudions séparément cet effet sur des problèmes de tailles "petite", "moyenne" et "grande".
"""

# ╔═╡ 75918730-8206-4ecc-9c7c-058890eb40a9
md"""
`gr17`

Ce problème peut être considéré comme étant de petite taille. Dans l'exemple qui suit, nous exécutons RSL en choisissant successivement chaque noeud comme racine, et nous nous intéressons à la distribution des coûts obtenus.
"""

# ╔═╡ d2d02246-b782-4beb-8224-f37294581735
md"""
Ces statistiques révèlent que l'étendue n'est pas négligeable entre le plus élevé et le plus faible de ces coûts. La série semble assez dispersée, avec un écart-type valant plus de 10% du coût optimal obtenu. L'écart interquartile est très faible en comparaison de l'étendue de la série, révélant que le choix de la racine est un élément crucial dans l'exécution de RSL sur cette instance.

Une étude plus large (nous ne reportons pas tous les résultats ici) révèle que cette tendance s'observe fréquemment sur tous les problèmes de petite taille. Intéressons-nous maintenant aux problèmes de taille "moyenne".
"""

# ╔═╡ 1b9402df-7d86-4b55-89dc-903ba13ac255
md"""
`brazil58`
"""

# ╔═╡ 079f00b3-d824-4bab-800c-8d50a7361b84
begin
	b58 = read_stsp("../../instances/stsp/brazil58.tsp")
	data_root_b58_rsl = Dict("root_id"=>Vector{String}(), "cost"=>Vector{Float64}())
	for node_id in keys(b58.nodes)
		cost, tour = rsl(b58; root_method="choice", root_id=node_id)
		push!(data_root_b58_rsl["root_id"], node_id)
		push!(data_root_b58_rsl["cost"], cost)
	end
	
	histogram(data_root_b58_rsl["cost"], xlabel="Coût de la tournée", ylabel="Effectif", legend=nothing)
end

# ╔═╡ 4a4a4775-3968-4696-98fa-c9d5e62d3105
begin
	b58_rsl_df = DataFrame(data_root_b58_rsl)
	boxplot(b58_rsl_df[!,"cost"], ylabel="Coût de la tournée", legend=nothing)
end

# ╔═╡ 019db836-517b-4a02-9c06-a06c1729796e
md"""
Nous constatons ici que les coûts sont moins dispersés en fonction de la racine choisie. Cette tendance se constate sur plusieurs instances de taille moyenne, bien que les écarts inter-quartiles soient parfois assez importants (c'est le cas sur le problème `gr48`, par exemple).

Intéressons-nous enfin aux problèmes de "grande" taille.
"""

# ╔═╡ c2c95b89-0d4c-4420-8f05-f957a6fa54d6
`brg180`

# ╔═╡ aba1531f-2d0e-4e3d-8234-26dcd0cc66f4
begin
	brg180 = read_stsp("../../instances/stsp/brg180.tsp")
	data_root_brg180_rsl = Dict("root_id"=>Vector{String}(), "cost"=>Vector{Float64}())
	for node_id in keys(brg180.nodes)
		cost, tour = rsl(brg180; root_method="choice", root_id=node_id)
		push!(data_root_brg180_rsl["root_id"], node_id)
		push!(data_root_brg180_rsl["cost"], cost)
	end
	
	histogram(data_root_brg180_rsl["cost"], xlabel="Coût de la tournée", ylabel="Effectif", legend=nothing)
end

# ╔═╡ d7fce58e-17f9-4b89-960a-647caa52f7a5
md"""
Sans grande surprise, les résultats de cette heuristique sont très mauvais sur les problèmes de grande taille. La solution de ce problème donne un coût de 1950... Il en va de même pour la plus grande instance de la librairie `TSPlib`, comptant 561 noeuds.

Passons maintenant à la méthode de Held et Karp, qui devrait nous permettre d'obtenir de meilleurs résultats.
"""

# ╔═╡ 9a890e9d-9f37-48ab-b787-62e51f210926
md"""
## Algorithme de montée de Held et Karp

Cet algorithme est plus complexe que RSL, et vient notamment avec un plus grand nombre d'hyperparamètres. La signature de notre implémentation est la suivante :

```julia
hk(G; start_node_id, mst_method, root_id, max_iters, τ, nesterov_weight, one_tree_heuristic)
```

Elle permet de choisir le noeud de départ de la tournée (s'il n'est pas précisé, il est choisi au hasard), la méthode de calcul des arbres de recouvrement minimaux (Prim ou Kruskal), d'imposer la racine des arbres de recouvrement minimaux, de contrôler les critères d'arrêt et 2 heuristiques ajoutées à l'algorithme. Ces deux heuristiques sont celles proposées par Keld Helsgaun dans *An Effective Implementation of the Lin-Kernighan Traveling Salesman Heuristic* et portent respectivement sur le choix du noeud "spécial" dans les 1-arbres de l'algorithme ainsi que sur la mise à jour du vecteur de translation des poids (avec une accélération à la Nesterov).

### Premiers résultats

Voici quelques résultats pour comparaison rapide avec RSL.
"""

# ╔═╡ 0f9a6692-f590-46ad-9d25-f672bc33b767
md"""
`dantzig42`
"""

# ╔═╡ e0790e8b-94f7-462d-8481-749ddddee383
begin
	d42_hk_cost, d42_hk_tour = hk(d42)
	println("Coût de la tournée proposée | ", d42_hk_cost)
	println("HK/opt (%) | ", d42_hk_cost / d42_opt * 100)
	println("RSL/HK (%) | ", d42_rsl_cost / d42_hk_cost * 100)
end

# ╔═╡ d017e10d-ed14-4851-8186-90146573db50
plot_tour(d42, d42_hk_tour)

# ╔═╡ 9d9dced4-94f0-4e00-ba2d-2d567ca71554
md"""
`bays29`
"""

# ╔═╡ b39a09ed-4899-4fbd-a774-a600a81a499d
begin
	bays29_hk_cost, bays29_hk_tour = hk(bays29)
	println("Coût de la tournée proposée | ", bays29_hk_cost)
	println("HK/opt (%) | ", bays29_hk_cost / bays29_opt * 100)
	println("RSL/HK (%) | ", bays29_rsl_cost / bays29_hk_cost * 100)
end

# ╔═╡ deebdce5-a8e2-4f74-9b5c-e29a7fb0f07c
plot_tour(bays29, bays29_hk_tour)

# ╔═╡ bc806372-6184-43c3-bdc1-5a09ac65ae64
md"""
Il apparaît que les tournées fournies par HK ont un coût inférieur à celles de RSL. Nous avons vérifié qu'avec les paramètres par défaut, ceci était toujours le cas. Les écarts relatifs

$\left\vert\frac{c_{HK}-c_{RSL}}{c_{RSL}}\right\vert$

sont présentés ci-dessous en % :
"""

# ╔═╡ 0980979c-8994-4966-a261-6908cb2f96e5
begin
	data_hk_prim = Dict{String, Float64}()
	folder = "../../instances/stsp/"
	for filename in readdir(folder)
		if filename in ["optimals.json", "pa561.tsp"]
			continue
		end
		G = read_stsp(folder * filename)
		cost_rsl, tour_rsl = rsl(G)
		cost_hk, tour_hk = hk(G)
		data_hk_prim[filename] = cost_hk
		println(filename, " | ", abs((cost_hk-cost_rsl)/cost_rsl) * 100)
	end
end

# ╔═╡ ec665440-5fb7-4ac2-826b-ae99e8118bc0
md"""
La plus grande instance, `pa561`, a été laissée de côté dans ces calculs car elle nécessite de réduire le critère d'arrêt pour produire un résultat en temps raisonnable.

### Effet du critère d'arrêt

Cet algorithme étant long à converger, nous choissons un critère d'arrêt et obtenons une tournée en appliquant un préordre au dernier 1-arbre obtenu. Bien que notre implémentation permette de limiter le nombre d'itérations, le critère le plus intéressant est une borne sur la norme 1 du sous-gradient $v$. Cette borne est calculée comme une proportion $\tau\vert N\vert$ du nombre de noeuds du graphe. Sa valeur par défaut est de $0.6\vert N\vert$. Nous tentons, sur quelques instances, de faire varier ce paramètre pour voir ses effets.
"""

# ╔═╡ 60f6aa25-8d42-4344-852c-9d7466b3fd09
md"""
`gr17`
"""

# ╔═╡ 333a9f56-fff1-42f0-b931-51fe64b0329e
begin
	gr17_hk_tau = Vector{Float64}()
	for τ in range(0.5, 0.1, length=10)
		cost, tour = hk(gr17; τ=τ)
		push!(gr17_hk_tau, cost)
	end
	scatter(range(0.5, 0.1, length=10), gr17_hk_tau, xaxis="τ", yaxis="Coût de la tournée", legend=nothing)
end

# ╔═╡ c0c1891f-7956-4803-a75d-f720d34b11a9
md"""
Nous constatons que l'amplitude n'est pas aussi significative qu'elle l'était pour le choix de la racine dans RSL. Voyons si ce constat tient toujours avec de plus grandes instances.

`brazil58`
"""

# ╔═╡ a281eed8-2508-421a-8d3e-d641933d7e86
begin
	b58_hk_tau = Vector{Float64}()
	for τ in range(0.5, 0.1, length=10)
		cost, tour = hk(b58; τ=τ)
		push!(b58_hk_tau, cost)
	end
	scatter(range(0.5, 0.1, length=10), b58_hk_tau, xaxis="τ", yaxis="Coût de la tournée", legend=nothing)
end

# ╔═╡ 8a7b3bd0-54c0-4eae-ace2-d09c5711b070
md"""
La tendance semble se confirmer ici.

`brg180`
"""

# ╔═╡ 92851e9f-29b3-4dcf-ba88-044d5883fdf8
begin
	brg180_hk_tau = Vector{Float64}()
	for τ in range(0.5, 0.1, length=10)
		cost, tour = hk(brg180; τ=τ)
		push!(brg180_hk_tau, cost)
	end
	scatter(range(0.5, 0.1, length=10), brg180_hk_tau, xaxis="τ", yaxis="Coût de la tournée", legend=nothing)
end

# ╔═╡ 18f9ed1b-d2e8-450c-b8ee-c1b3de57850e
md"""
Les résultats sont toujours bien loin de l'optimal connu, mais largement meilleurs que RSL. Le critère d'arrêt semble ici pouvoir améliorer considérablement la solution.

### Effet de la méthode de calcul de l'arbre de recouvrement minimal

Tous les résultats présentés jusqu'ici ont été obtenus avec l'algorithme de Prim. Étudions les résultats obtenus avec l'algorithme de Kruskal. Nous présentons les écarts relatifs

$\frac{c_{\text{Prim}}-c_{\text{Kruskal}}}{c_{\text{Prim}}}$
"""

# ╔═╡ e325e8c9-22f3-4156-85bf-6150ab55589d
begin
	data_hk_kruskal = Dict{String, Float64}()
	for filename in readdir(folder)
		if filename in ["optimals.json", "pa561.tsp"]
			continue
		end
		G = read_stsp(folder * filename)
		cost_hk, tour_hk = hk(G; mst_method="kruskal")
		data_hk_kruskal[filename] = cost_hk
		println(filename, " | ", (data_hk_prim[filename]-data_hk_kruskal[filename])/data_hk_prim[filename] * 100)
	end
end

# ╔═╡ 1f5c3b8e-755d-445e-a339-b5db0a224e5b
md"""
Les écarts sont assez peu significatifs, sauf sur l'instance à 180 noeuds qui, nous l'avons vu plus tôt, donne de toutes façons des résultats bien loin de l'optimal.

Nous avons également fait varier le coefficient $\tau$ du critère d'arrêt avec l'algorithme de Kruskal, et nous observons les mêmes tendances qu'avec celui de Prim.

### Effet du choix du noeud de départ

Nous répétons les essais faits avec RSL.
"""

# ╔═╡ 072a2818-c1ca-4550-a185-976244a63296
md"""
`gr17`
"""

# ╔═╡ 1e472aa7-0c46-473d-8df7-60bbfeb001c1
begin
	data_root_gr17_hk = Dict("root_id"=>Vector{String}(), "cost"=>Vector{Float64}())
	for node_id in keys(gr17.nodes)
		cost, tour = hk(gr17; start_node_id=node_id)
		push!(data_root_gr17_hk["root_id"], node_id)
		push!(data_root_gr17_hk["cost"], cost)
	end

	histogram(data_root_gr17_hk["cost"], xlabel="Coût de la tournée", ylabel="Effectif", legend=nothing)
end

# ╔═╡ 07abd83b-4e45-479e-af15-cbbf3d2801c7
begin
	gr17_hk_df = DataFrame(data_root_gr17_hk)
	boxplot(gr17_hk_df[!,"cost"], ylabel="Coût de la tournée", legend=nothing)
end

# ╔═╡ 0cb5edbc-18e6-4afe-88a3-62afb6da61bf
md"""
`brazil58`
"""

# ╔═╡ 2abe5a29-1963-4cad-aa16-d0ec45b37337
begin
	data_root_b58_hk = Dict("root_id"=>Vector{String}(), "cost"=>Vector{Float64}())
	for node_id in keys(b58.nodes)
		cost, tour = hk(b58; start_node_id=node_id)
		push!(data_root_b58_hk["root_id"], node_id)
		push!(data_root_b58_hk["cost"], cost)
	end
	
	histogram(data_root_b58_hk["cost"], xlabel="Coût de la tournée", ylabel="Effectif", legend=nothing)
end

# ╔═╡ 38f36eb5-832b-4fb9-be22-9ebc2fa49624
begin
	b58_hk_df = DataFrame(data_root_b58_hk)
	boxplot(b58_hk_df[!,"cost"], ylabel="Coût de la tournée", legend=nothing)
end

# ╔═╡ e0d4f3c0-5e35-49bc-9279-1fbeffe0b053
md"""
Cette fois-ci, les valeurs extrêmes de la série sont situées dans les coûts supérieurs, montrant que HK donne de bons résultats assez peu dépendants au choix du noeud de départ de la tournée.
"""

# ╔═╡ 6b5034b7-3990-4bc6-a93b-713ac1d605a8
md"""
### Étude de l'effet des heuristiques

#### Heuristique sur le 1-arbre

La première heuristique porte sur le choix du noeud "spécial" (celui induisant le cycle) dans les 1-arbres. Pour toutes les instances (sauf la plus grande), nous calculons le gain relatif apporté par cette heuristique. Puisqu'elle est postérieure au calcul de l'arbre de recouvrement minimal, nous ne testons pas ce paramètre en conjonction avec le choix de Prim ou Kruskal.
"""

# ╔═╡ 500e1919-c79e-4290-bbb3-b526df0cffa1
begin
	data_hk_nheur = Dict{String, Float64}()
	for filename in readdir(folder)
		if filename in ["optimals.json", "pa561.tsp"]
			continue
		end
		G = read_stsp(folder * filename)
		cost_hk, tour_hk = hk(G; one_tree_heuristic=false)
		data_hk_nheur[filename] = cost_hk
		println(filename, " | ", (data_hk_nheur[filename]-data_hk_prim[filename])/data_hk_nheur[filename] * 100)
	end
end

# ╔═╡ e1468915-54a1-4b50-90ea-bfc64040b28f
md"""
On observe que l'heuristique amène dans certains cas un gain important (jusqu'à 15% du coût), mais peut être préjudiciable dans d'autres. Sa pertinence ne peut être jugée qu'à l'échelle d'un seul problème.

#### Accélération à la Nesterov

La dernière heuristique que nous testons porte sur la mise à jour du vecteur $\pi$ de translation des poids. Voici les % d'écarts relatifs constatés (avec pour base la version sans accélération).
"""

# ╔═╡ 6b2cf455-ba1d-48cc-b02b-6fad54a6a83c
begin
	data_hk_nnest = Dict{String, Float64}()
	for filename in readdir(folder)
		if filename in ["optimals.json", "pa561.tsp"]
			continue
		end
		G = read_stsp(folder * filename)
		cost_hk, tour_hk = hk(G; nesterov_weight=nothing)
		data_hk_nnest[filename] = cost_hk
		println(filename, " | ", (data_hk_nnest[filename]-data_hk_prim[filename])/data_hk_nnest[filename] * 100)
	end
end

# ╔═╡ f8728389-84c2-434c-93ca-1c0dbbee8135
md"""
Sur ces instances-ci, cette heuristique semble globalement plutôt préjudiciable.

### Instance à 561 noeuds

La résolution du problème le plus grand du jeu de données nécessite un temps de calcul déraisonnable. Nous essayons d'obtenir une solution en fixant le nombre maximal d'itérations à $10^3$. Les résultats sont les suivants :
"""

# ╔═╡ 382758b9-b704-49e1-9d3c-33eebe9b51ca
begin
	pa561 = read_stsp("../../instances/stsp/pa561.tsp")
	pa561_cost, pa561_tour = hk(pa561; max_iters=Int(1e3))
	pa561_opt = 2763
	println("Coût de la tournée obtenue | ", pa561_cost)
	println("Coût de la tournée optimale | ", pa561_opt)
	println("HK/opt (%) | ", pa561_cost/pa561_opt * 100)
end

# ╔═╡ 738f2597-2e40-42a6-b6a3-7a49ea0f4987
md"""
## Conclusion

En conclusion, nos implémentations des algorithmes de RSL et de HK fournissent des résultats satisfaisants et globalement cohérents avec la théorie. Même si certaines tendances ont pu être dégagées sur les paramètres et les différentes heuristiques à l'intérieur de HK, le constat global est que le choix doit être fait à l'échelle d'un problème précis.

Notons enfin qu'un autre paramètre que nous avons essayé de modifier porte sur le critère d'arrêt. Nous utilisions initialement la norme 0 sur le sous-gradient au lieu de la norme 1. Les nombreuses discontinuités des problèmes répercutées dans la norme 0 ont cependant mené à de moins bons résultats.
"""

# ╔═╡ Cell order:
# ╟─a761fd2c-a29d-11ef-030c-5b7d55f07fe9
# ╟─0f15ea4a-7a45-441c-9c63-1728de10b269
# ╠═3f521035-d2e9-4f82-8bdc-07dcd141c2cc
# ╟─85cbc46c-b0c2-4957-ba4a-7f49693f5ba1
# ╟─6852139e-9169-4d90-a1ca-89a95de62da1
# ╟─399519e2-ef90-45e9-ae07-87014655d698
# ╟─2825b770-24ff-4222-89b2-96bf7e0a7fc1
# ╟─a00513aa-598a-475b-8403-f5e4d0dfcafa
# ╟─def153fe-cca4-4110-977f-e153f0fb1f2b
# ╟─f8f39406-facf-453e-99ee-6a72f960f67e
# ╟─5c7c403b-5ad5-4826-acec-14ca5964538c
# ╟─420e54b6-b0d4-4daa-a951-94e52c383e06
# ╟─dad3ebc5-e2a3-41a3-b047-1bda5dd2246c
# ╟─75918730-8206-4ecc-9c7c-058890eb40a9
# ╟─9cd6173c-da3f-4350-9e74-d281bab970f4
# ╟─7ff539cd-1d3f-4178-8d33-7cc6c3381d3d
# ╟─d2d02246-b782-4beb-8224-f37294581735
# ╟─1b9402df-7d86-4b55-89dc-903ba13ac255
# ╟─079f00b3-d824-4bab-800c-8d50a7361b84
# ╟─4a4a4775-3968-4696-98fa-c9d5e62d3105
# ╟─019db836-517b-4a02-9c06-a06c1729796e
# ╟─c2c95b89-0d4c-4420-8f05-f957a6fa54d6
# ╟─aba1531f-2d0e-4e3d-8234-26dcd0cc66f4
# ╟─d7fce58e-17f9-4b89-960a-647caa52f7a5
# ╟─9a890e9d-9f37-48ab-b787-62e51f210926
# ╟─0f9a6692-f590-46ad-9d25-f672bc33b767
# ╟─e0790e8b-94f7-462d-8481-749ddddee383
# ╟─d017e10d-ed14-4851-8186-90146573db50
# ╟─9d9dced4-94f0-4e00-ba2d-2d567ca71554
# ╟─b39a09ed-4899-4fbd-a774-a600a81a499d
# ╟─deebdce5-a8e2-4f74-9b5c-e29a7fb0f07c
# ╟─bc806372-6184-43c3-bdc1-5a09ac65ae64
# ╟─0980979c-8994-4966-a261-6908cb2f96e5
# ╟─ec665440-5fb7-4ac2-826b-ae99e8118bc0
# ╟─60f6aa25-8d42-4344-852c-9d7466b3fd09
# ╟─333a9f56-fff1-42f0-b931-51fe64b0329e
# ╟─c0c1891f-7956-4803-a75d-f720d34b11a9
# ╟─a281eed8-2508-421a-8d3e-d641933d7e86
# ╟─8a7b3bd0-54c0-4eae-ace2-d09c5711b070
# ╟─92851e9f-29b3-4dcf-ba88-044d5883fdf8
# ╟─18f9ed1b-d2e8-450c-b8ee-c1b3de57850e
# ╟─e325e8c9-22f3-4156-85bf-6150ab55589d
# ╟─1f5c3b8e-755d-445e-a339-b5db0a224e5b
# ╟─072a2818-c1ca-4550-a185-976244a63296
# ╟─1e472aa7-0c46-473d-8df7-60bbfeb001c1
# ╟─07abd83b-4e45-479e-af15-cbbf3d2801c7
# ╟─0cb5edbc-18e6-4afe-88a3-62afb6da61bf
# ╟─2abe5a29-1963-4cad-aa16-d0ec45b37337
# ╟─38f36eb5-832b-4fb9-be22-9ebc2fa49624
# ╟─e0d4f3c0-5e35-49bc-9279-1fbeffe0b053
# ╟─6b5034b7-3990-4bc6-a93b-713ac1d605a8
# ╟─500e1919-c79e-4290-bbb3-b526df0cffa1
# ╟─e1468915-54a1-4b50-90ea-bfc64040b28f
# ╟─6b2cf455-ba1d-48cc-b02b-6fad54a6a83c
# ╟─f8728389-84c2-434c-93ca-1c0dbbee8135
# ╟─382758b9-b704-49e1-9d3c-33eebe9b51ca
# ╟─738f2597-2e40-42a6-b6a3-7a49ea0f4987
