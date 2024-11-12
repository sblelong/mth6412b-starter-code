export dfs

function dfs(G::Graph{T}) for node in nodes(G)
    visited(node) || dfs_visit(G, node)
    end
    return end
    function dfs_visit(G::Graph{T}, node::MarkedNode{T})
    set_visited!(node) # node devient la racine d'une nouvelle arborescence
    for neighbor in neighbors(G, node)
    visited(neighbor) && continue set_parent!(neighbor, node)
    dfs_visit(G, neighbor)
    end
    return
    
    end