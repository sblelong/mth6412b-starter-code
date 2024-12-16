### A Pluto.jl notebook ###
# v0.20.0

using Markdown
using InteractiveUtils

# ╔═╡ c3f1854d-49d1-48e8-b89f-af30e5204f2d
begin
	using Pkg
	Pkg.activate(Base.current_project())
	Pkg.instantiate()
	using Revise
	using STSP
end

# ╔═╡ 620031c2-ba6c-11ef-34a6-c5298a536046
md"""
Maxence Gollier, Sacha Benarroch-Lelong

MTH6412B, Polytechnique Montréal, Automne 2024
## Projet voyageur de commerce - Phase 5

Notre code est disponible sur [ce dépôt GitHub](https://github.com/sblelong/mth6412b-starter-code). Il est organisé selon une structure de projet Julia. L'environnement associé est nommé `STSP`.

La cinquième phase est consacrée à l'application des algorithmes de calcul de tournées optimales à la reconstitution d'images.
"""

# ╔═╡ 766f40c2-e3b9-431b-b744-7e6cbdb2d6db
md"""
Activation de l'environnement
"""

# ╔═╡ 13f25ecf-f907-4424-b56f-e2adb54941c1
images = ["abstract-light-painting", "alaska-railroad", "blue-hour-paris", "lower-kananaskis-lake", "marlet2-radio-board", "nikos-cat", "pizza-food-wallpaper", "the-enchanted-garden", "tokyo-skytree-aerial"]

# ╔═╡ ece16be6-cbc1-4178-8847-423d0b386b2a
md"""
## Préambule

### Adaptation de RSL

Dans cette mise en pratique, l'algorithme de Rosenkrantz, Stearns et Lewis implémenté en phase 4 échoue à cause du noeud artificiel 0 ajouté aux graphes : l'arbre de recouvrement minimal calculé par l'algorithme de Prim utilise seulement les arêtes de coût 0 qui relient le noeud 0 au reste du graphe. La tournée obtenue n'est donc pas pertinente.

Pour traiter ce problème, nous avons modifié notre implémentation de RSL pour ajouter une fonctionnalité qui permet de retirer le noeud 0 et toutes ses arêtes sortantes avant l'application de l'algorithme de Prim.

### Reproduction des résultats

Les résultats de reconstitution d'images présentés dans ce rapport peuvent être reproduits à l'aide des fonctions présentes dans le fichier `main.jl` du dossier `src/phase5` dans notre dépôt Git. Ces fonctions doivent exécutées depuis le dossier `src/phase5` pour que les fichiers puissent être trouvés correctement.

Une fonction est dédiée à chaque algorithme :

```julia
unshred_rsl(image_name::String)
```

permet de reconstituer une image avec RSL. L'argument `image_name` est le nom de l'image désirée, sans extension (voir la liste `images` définie dans une cellule plus haut). La fonction affiche l'image reconstituée à côté de l'image originale, et le coût de la tournée identifiée. Pour optimiser le résultat obtenu, la fonction calcule des tournées partant de chacun des noeuds et affiche le meilleur résultat obtenu.

```julia
unshred_hk(image_name::String; start_node_id::Union{Nothing,String}=nothing, mst_method="prim", τ::Float64=0.4, nesterov_weight::Union{Float64,Nothing}=0.7, one_tree_heuristic::Bool=true)
```

effectue la même chose mais avec l'algorithme de montée de Held et Karp. Les arguments supplémentaires sont ceux de notre implémentation de HK (voir phase 4).

*Précision : nos méthodes reconstituent les images en partant de la première bande présentée dans la version déchiquetée. Ceci explique la présence de certains sauts dans les images reconstituées.*
"""

# ╔═╡ 42ee1ca1-5f21-45d9-9f51-e54916e5ee5e
md"""
## Reconstitution des images

### `abstract-light-painting`
"""

# ╔═╡ dd70b729-4d1e-44e6-814d-c810afec12d9
md"""
Reconstitution avec RSL :
"""

# ╔═╡ 6ddc2a5d-01b8-468b-b4f0-fa6b0a9b0d0a
begin
	tour_rsl_1, cost_rsl_1 = unshred_rsl("abstract-light-painting")
	reconstruct_and_display("abstract-light-painting", tour_rsl_1, cost_rsl_1, "RSL")
end

# ╔═╡ 38af0cec-a133-45d6-bd4d-cbc0466f4a94
md"""
Reconstitution avec HK :
"""

# ╔═╡ 314b378f-655c-4376-a6bf-2ce08aa01aeb
begin
	tour_hk_1, cost_hk_1 = unshred_hk("abstract-light-painting"; τ=1e-3)
	reconstruct_and_display("abstract-light-painting", tour_hk_1, cost_hk_1, "HK")
end

# ╔═╡ 25300e88-7f57-4baa-be98-6eb0c804d2d2
md"""
Après plusieurs tests, il s'avère que l'hyperparamètre ayant le plus d'impact sur la qualité de la reconstitution est le critère d'arrêt de HK. Nous obtenons cette reconstitution optimale (modulo une inversion de l'image) avec $\tau=10^{-3}$.

Nous constatons que les tournées identifiées par RSL et HK présentent des coûts similaires. On a :
"""

# ╔═╡ e1644f39-de89-46d9-bef0-ad48e60c167b
println("Rapport HK/RSL (%) : ", cost_hk_1 / cost_rsl_1 * 100)

# ╔═╡ 515e4121-3af0-42b0-b227-12836f18331f
md"""
### `alaska-railroad`
"""

# ╔═╡ 54f9fa8c-d5de-48c8-9ed3-0929e91b23ce
begin
	tour_rsl_2, cost_rsl_2 = unshred_rsl("alaska-railroad")
	reconstruct_and_display("alaska-railroad", tour_rsl_2, cost_rsl_2, "RSL")
end

# ╔═╡ 4cebd344-7642-4613-8180-da0168173bcd
begin
	tour_hk_2, cost_hk_2 = unshred_hk("alaska-railroad", τ=1e-3)
	reconstruct_and_display("alaska-railroad", tour_hk_2, cost_hk_2, "HK")
end

# ╔═╡ 5f7a8e86-7f87-458f-acfc-7360f0160d0e
md"""
De la même manière, on constate que les tournées produites par les 2 algorithmes sont à peu près de même coût, mais l'image est parfaitement reconstruite par HK : la diminution de la tolérance sur le critère d'arrêt a suffi à obtenir une bonne performance.
"""

# ╔═╡ 420b19ab-5111-4d55-849f-216068f2f177
println("Rapport HK/RSL (%) : ", cost_hk_2 / cost_rsl_2 * 100)

# ╔═╡ 9cd0d3c8-41b7-4291-b7bb-56d744463d73
md"""
### `blue-hour-paris`
"""

# ╔═╡ 82798fa1-fb1b-4154-8f0b-6166f1bf6ff5
begin
	tour_rsl_3, cost_rsl_3 = unshred_rsl("blue-hour-paris")
	reconstruct_and_display("blue-hour-paris", tour_rsl_3, cost_rsl_3, "RSL")
end

# ╔═╡ 2ac68ed5-6a36-4099-b840-8235c2729bce
md"""
La meilleure reconstitution faite par RSL possède ici quelques défauts, que l'on peut observer sur certaines bandes à droite de l'image.
"""

# ╔═╡ 30a99031-40c3-4aeb-a1cf-0dbdb3a807a9
begin
	tour_hk_3, cost_hk_3 = unshred_hk("blue-hour-paris", τ=1.7e-3, nesterov_weight=0.3)
	reconstruct_and_display("blue-hour-paris", tour_hk_3, cost_hk_3, "HK")
end

# ╔═╡ b34c8b26-c654-4736-8ab3-f399ce43bd3b
md"""
Ici, nous constatons que HK a du mal à converger vers une solution optimale : un $\tau$ inférieur à $1.7\times 10^{-3}$ empêche l'algorithme de converger. La diminution du poids dans l'accélération à la Nesterov permet d'alléger le poids de calcul. Nous tentons d'utiliser le noeud de départ identifié comme le meilleur par RSL pour relancer une exécution de HK.
"""

# ╔═╡ ada3dd88-382b-4ebc-83b1-98d66146510d
begin
	tour_hk_3b, cost_hk_3b = unshred_hk("blue-hour-paris", τ=1.7e-3, nesterov_weight=nothing, start_node_id=string(tour_rsl_3[1]))
	reconstruct_and_display("blue-hour-paris", tour_hk_3b, cost_hk_3b, "HK")
end

# ╔═╡ 8a158c97-b283-4d29-b3a2-77d656632847
md"""
La sélection d'un "bon" noeud de départ permet une convergence de HK vers un meilleur résultat. Sans la sélection du noeud de départ, les coûts des tournées se comparent comme suit :
"""

# ╔═╡ 0fdd06e5-6441-4fc0-8d91-b3028af39755
println("Rapport HK/RSL (%) : ", cost_hk_3 / cost_rsl_3 * 100)

# ╔═╡ 544d9141-3d20-4100-8fae-bc4aa4b29933
md"""
Et les coûts des tournées après sélection du noeud optimal de départ :
"""

# ╔═╡ 21742563-a865-482c-8537-f06571121a59
println("Rapport HK/RSL (%) : ", cost_hk_3b / cost_rsl_3 * 100)

# ╔═╡ b1621595-9627-46b5-848a-e7271455de9d
md"""
La deuxième tournée identifiée par HK présente un coût légèrement meilleur, mais le résultat visuel est considérablement meilleur.
"""

# ╔═╡ 5d77139f-17dd-4f56-9b85-debeb18b7158
md"""
### `lower-kananaskis-lake`
"""

# ╔═╡ 5e8c87e1-cc8f-4c6e-ae8a-9552fdd9ba9f
begin
	tour_rsl_4, cost_rsl_4 = unshred_rsl("lower-kananaskis-lake")
	reconstruct_and_display("lower-kananaskis-lake", tour_rsl_4, cost_rsl_4, "RSL")
end

# ╔═╡ 6e52e10b-c982-4d0d-a7ca-724c2869494c
begin
	tour_hk_4, cost_hk_4 = unshred_hk("lower-kananaskis-lake"; τ=1e-3)
	reconstruct_and_display("lower-kananaskis-lake", tour_hk_4, cost_hk_4, "HK")
end

# ╔═╡ 9542bc23-f87e-4478-bb7a-37daab817e8c
md"""
Ici encore, avec un choix optimal du noeud de départ, les deux algorithmes donnent une bonne reconstitution. Il ne faut pas oublier que le coût de calcul exigé par RSL devient largement supérieur, puisqu'on doit l'exécuter autant de fois qu'il y a de noeuds dans le graphe, i.e. 600 ici.
"""

# ╔═╡ 1bd8c8c0-74ea-465e-a047-29ae55db5476
println("Rapport HK/RSL (%) : ", cost_hk_4 / cost_rsl_4 * 100)

# ╔═╡ 50dfd4d4-67e2-4d76-a7b4-a793e312e954
md"""
### `marlet2-radio-board`
"""

# ╔═╡ f676e7a8-4db8-4406-8e1c-58593ed29217
begin
	tour_rsl_5, cost_rsl_5 = unshred_rsl("marlet2-radio-board")
	reconstruct_and_display("marlet2-radio-board", tour_rsl_5, cost_rsl_5, "RSL")
end

# ╔═╡ 3a3077a7-ab60-4a98-9205-1012d1014024
begin
	tour_hk_5, cost_hk_5 = unshred_hk("marlet2-radio-board"; τ=1e-3)
	reconstruct_and_display("marlet2-radio-board", tour_hk_5, cost_hk_5, "HK")
end

# ╔═╡ 368e4272-64ad-4449-bd38-3f09d63d6640
md"""
Ici, la tournée identifiée par HK est meilleure que celle identifiée par RSL, mais les reconstitutions sont de qualités semblables.
"""

# ╔═╡ 56ceaf3d-b525-4aef-b520-7320f06901f2
println("Rapport HK/RSL (%) : ", cost_hk_5 / cost_rsl_5 * 100)

# ╔═╡ 6b166ef6-6fce-4053-845b-b2ca3c1ed76a
md"""
### `nikos-cat`
"""

# ╔═╡ ed84d2c9-725a-4a90-982b-ae4fc08db54c
begin
	tour_rsl_6, cost_rsl_6 = unshred_rsl("nikos-cat")
	reconstruct_and_display("nikos-cat", tour_rsl_6, cost_rsl_6, "RSL")
end

# ╔═╡ 5f1cbaa4-ba0a-4ba3-a0ab-73e0fd44a021
md"""
À régler
- Pourquoi HK reconstruit certaines images avec un morceau dans le mauvais sens : parce qu'il fallait encore réduire le critère de convergence. Le mentionner, ça peut être intéressant.
- Tuner les paramètres de HK pour chaque image
- Voir comment faire marcher RSL
- Fin officielle de la session
"""

# ╔═╡ Cell order:
# ╟─620031c2-ba6c-11ef-34a6-c5298a536046
# ╟─766f40c2-e3b9-431b-b744-7e6cbdb2d6db
# ╟─c3f1854d-49d1-48e8-b89f-af30e5204f2d
# ╟─13f25ecf-f907-4424-b56f-e2adb54941c1
# ╟─ece16be6-cbc1-4178-8847-423d0b386b2a
# ╟─42ee1ca1-5f21-45d9-9f51-e54916e5ee5e
# ╟─dd70b729-4d1e-44e6-814d-c810afec12d9
# ╟─6ddc2a5d-01b8-468b-b4f0-fa6b0a9b0d0a
# ╟─38af0cec-a133-45d6-bd4d-cbc0466f4a94
# ╟─314b378f-655c-4376-a6bf-2ce08aa01aeb
# ╟─25300e88-7f57-4baa-be98-6eb0c804d2d2
# ╟─e1644f39-de89-46d9-bef0-ad48e60c167b
# ╟─515e4121-3af0-42b0-b227-12836f18331f
# ╟─54f9fa8c-d5de-48c8-9ed3-0929e91b23ce
# ╟─4cebd344-7642-4613-8180-da0168173bcd
# ╟─5f7a8e86-7f87-458f-acfc-7360f0160d0e
# ╟─420b19ab-5111-4d55-849f-216068f2f177
# ╟─9cd0d3c8-41b7-4291-b7bb-56d744463d73
# ╟─82798fa1-fb1b-4154-8f0b-6166f1bf6ff5
# ╟─2ac68ed5-6a36-4099-b840-8235c2729bce
# ╟─30a99031-40c3-4aeb-a1cf-0dbdb3a807a9
# ╟─b34c8b26-c654-4736-8ab3-f399ce43bd3b
# ╟─ada3dd88-382b-4ebc-83b1-98d66146510d
# ╟─8a158c97-b283-4d29-b3a2-77d656632847
# ╟─0fdd06e5-6441-4fc0-8d91-b3028af39755
# ╟─544d9141-3d20-4100-8fae-bc4aa4b29933
# ╟─21742563-a865-482c-8537-f06571121a59
# ╟─b1621595-9627-46b5-848a-e7271455de9d
# ╟─5d77139f-17dd-4f56-9b85-debeb18b7158
# ╟─5e8c87e1-cc8f-4c6e-ae8a-9552fdd9ba9f
# ╟─6e52e10b-c982-4d0d-a7ca-724c2869494c
# ╟─9542bc23-f87e-4478-bb7a-37daab817e8c
# ╟─1bd8c8c0-74ea-465e-a047-29ae55db5476
# ╟─50dfd4d4-67e2-4d76-a7b4-a793e312e954
# ╟─f676e7a8-4db8-4406-8e1c-58593ed29217
# ╟─3a3077a7-ab60-4a98-9205-1012d1014024
# ╟─368e4272-64ad-4449-bd38-3f09d63d6640
# ╟─56ceaf3d-b525-4aef-b520-7320f06901f2
# ╟─6b166ef6-6fce-4053-845b-b2ca3c1ed76a
# ╠═ed84d2c9-725a-4a90-982b-ae4fc08db54c
# ╟─5f1cbaa4-ba0a-4ba3-a0ab-73e0fd44a021
