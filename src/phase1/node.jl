export AbstractNode, Node
export name, data, show

import Base.show

"""Type abstrait dont d'autres types de noeuds dériveront."""
abstract type AbstractNode{T} end

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

# L'absence de documentation de cette méthode est volontaire.
name(node::AbstractNode) = node.name

"""
	data(node::AbstractNode)

Renvoie les données contenues dans le noeud.
"""
data(node::AbstractNode) = node.data

"""
		show(node::AbstractNode)
	
	Affiche un noeud.
"""
function show(node::AbstractNode)
  println("Node ", name(node), ", data: ", data(node))
end
