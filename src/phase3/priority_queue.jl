import Base.length, Base.push!, Base.popfirst!
import Base.show

export PrimPriorityQueue
"""Type abstrait dont d'autres types de files dériveront."""
abstract type AbstractQueue end


"""Retire et renvoie l'objet du début de la file."""
popfirst!(q::AbstractQueue) = popfirst!(q.items)

"""Indique si la file est vide."""
is_empty(q::AbstractQueue) = length(q.items) == 0

"""Donne le nombre d'éléments sur la file."""
length(q::AbstractQueue) = length(q.items)

"""Affiche une file."""
show(q::AbstractQueue) = show(q.items)

"""File de priorité."""
mutable struct PrimPriorityQueue <: AbstractQueue
    items::Dict{String, Float64}
    order::String
end

"""Ajoute `item` à la fin de la file `s`."""
function push!(q::PrimPriorityQueue, name::String, priority::Float64)
    q.items[name] = priority
    q
end

PrimPriorityQueue() = PrimPriorityQueue(Dict{String, Float64}(), "max")

"""Retire et renvoie l'élément ayant la plus haute priorité."""
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
