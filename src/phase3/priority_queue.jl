import Base.length, Base.push!, Base.popfirst!
import Base.show

export PrimPriorityQueue
"""Type abstrait dont d'autres types de files dériveront."""
abstract type AbstractQueue{U} end

"""
  popfirst!(q)

Retire et renvoie le premier élément d'une file abstraite.
"""
popfirst!(q::AbstractQueue) = popfirst!(q.items)

"""
  is_empty(q)

Indique si une file abstraite est vide.
"""
is_empty(q::AbstractQueue) = length(q.items) == 0

"""
  length(q)

Retourne le nombre d'éléments d'une file abstraite.
"""
length(q::AbstractQueue) = length(q.items)

"""
  show(q)

Affiche les éléments d'une file abstraite.
"""
show(q::AbstractQueue) = show(q.items)

"""Type représentant une implémentation d'une file de priorité permettant une implémentation efficace de l'algorithme de Prim.

Cette structure de donnée stocke des identifiants de noeuds ainsi que des priorités dont le type est paramétrique dans le dictionnaire `items`. 
L'ordre de supression des éléments de la file est indiqué par `order` dont la valeur par défaut est `"max"`.
Lors d'un appel à `popfirst!`, si l'ordre est max, la paire identifiant-priorité ayant la priorité la plus élevée est supprimée.
Si l'ordre choisi est "min" alors c'est la paire ayant la plus petite priorité qui est supprimée.
"""
mutable struct PrimPriorityQueue{U} <: AbstractQueue{U}
  items::Dict{String,U}
  order::String
end

"""
  push!(q, name, priority)

Rajoute une paire identifiant priorité à une file de priorité de Prim. 

#Arguments
- q (`PrimPriorityQueue`): La file de priorité permettant une implémentation efficace de l'algorithme de Prim.
- name (`String`): Un identifiant de noeud qu'on ajoute à la file de priorité.
- priority (`U`): La priorité de l'identifiant dans la file dont le type est celui des poids des arêtes du graphe que l'algorithme de Prim résout.
"""
function push!(q::PrimPriorityQueue, name::String, priority::U) where {U}
  q.items[name] = priority
  q
end

"""
  PrimPriorityQueue{U}()

Initialise une file de priorité de Prim de type paramétrique U vide.
"""
PrimPriorityQueue{U}() where {U} = PrimPriorityQueue(Dict{String,U}(), "max")

"""
  popfirst!(q)

Si l'ordre de la file (stocké dans `q.order`) est `"max"`, retire et renvoie un élément de la file ayant la plus grande priorité.
Si l'ordre de la file (stocké dans `q.order`) est `"min"`, retire et renvoie un élément de la file ayant la plus petite priorité.
"""
function popfirst!(q::PrimPriorityQueue)
  highest_key, highest = first(q.items)
  for (key, value) in q.items
    if (value > highest && q.order == "max") || (value < highest && q.order == "min")
      highest = value
      highest_key = key
    end
  end
  delete!(q.items, highest_key)
  return (highest_key, highest)
end
