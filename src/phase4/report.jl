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

Tous nos résultats peuvent être reproduits avec des instances différentes grâce aux fonctions du fichier `main.jl` présent sur notre dépôt Git. La fonction

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
rsl(G; mst_method, root_method)
```

Elle permet de choisir la méthode désirée pour le calcul de l'arbre de recouvrement minimal, et pour déterminer la racine de cet arbre.
"""

# ╔═╡ 399519e2-ef90-45e9-ae07-87014655d698
md"""
### RSL avec l'algorithme de Prim

Nous montrons ici les résultats de notre implémentation de RSL sur quelques instances de TSP symétriques.

*Note : pour pouvoir afficher les résultats, nous n'utilisons pas ces fonctions qui poseraient des problèmes de chemin dans un carnet Pluto.*
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
`gr120`
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

# ╔═╡ 9a890e9d-9f37-48ab-b787-62e51f210926
md"""
## Algorithme de Held et Karp
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
# ╠═9a890e9d-9f37-48ab-b787-62e51f210926
