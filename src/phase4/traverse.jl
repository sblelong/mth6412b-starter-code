export find_children, preorder

function find_children(edges::Vector{Edge{U}}, node_id::String, parent_id::String="-1") where {U}
    children = Vector{String}()

    for edge in edges
        if edge.node1_id == node_id && edge.node2_id != node_id && edge.node2_id != parent_id
            push!(children, edge.node2_id)
        elseif edge.node2_id == node_id && edge.node1_id != parent_id
            push!(children, edge.node1_id)
        end
    end
    return children
end

"""
Réalise un parcours pré-ordre de l'arbre n-aire passé en argument.

# Type de retour
`Vector{String}` : liste des identifiants des noeuds dans l'ordre de visite du parcours pré-ordre.
"""
function preorder(edges::Vector{Edge{U}}, node_id::String) where {U}
    order = Vector{String}()
    visited = Vector{String}()
    preorder_step!(edges, node_id, "-1", order)
    return order
end

function preorder_step!(edges::Vector{Edge{U}}, node_id::String, parent_id::String, order::Vector{String}) where {U}

    # Si le noeud a déjà été visité (cas particulier pour un 1-tree qui introduit des cycles), return
    if node_id in order
        return
    end
    push!(order, node_id)

    children = find_children(edges, node_id, parent_id)

    # Retirer le noeud parent de la liste
    deleteat!(children, findall(x -> x == parent_id, children))

    # Si on est sur une feuille, return
    if length(children) == 0
        return
    end

    # Pour chaque enfant, appeler preorder
    for child in children
        preorder_step!(edges, child, node_id, order)
    end
    return
end