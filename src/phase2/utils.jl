export sort_edges

function merge_pairs(left::Vector{Pair{String,Edge{Float64}}}, right::Vector{Pair{String,Edge{Float64}}})
    sorted_pairs = Pair{String,Edge{Float64}}[]

    nl, nr = length(left), length(right)

    i = j = 1

    while i <= nl && j <= nr
        if left[i].second.data < right[j].second.data
            push!(sorted_pairs, left[i])
            i += 1
        else
            push!(sorted_pairs, right[j])
            j += 1
        end
    end

    while i <= nl
        push!(sorted_pairs, left[i])
        i += 1
    end
    while j <= nr
        push!(sorted_pairs, right[j])
        j += 1
    end
    return sorted_pairs
end

function merge_sort_dict(pairs::Vector{Pair{String,Edge{Float64}}})
    n = length(pairs)

    if n > 1
        mid = n ÷ 2
        left_pairs = pairs[1:mid]
        right_pairs = pairs[mid+1:end]
        left_sorted = merge_sort_dict(left_pairs)
        right_sorted = merge_sort_dict(right_pairs)
        merged_pairs = merge_pairs(left_sorted, right_sorted)
        if n == 406
            println(merged_pairs)
        end
        return merged_pairs
    else
        return pairs
    end
end

"""
    sort_edges(edges)

Trie un dictionnaire d'arétes dans l'ordre croissant ou décroissant de leurs poids. Utilise un tri par fusion.

Arguments
    edges::Dict{String,Edge}: le dictionnaire d'arêtes à trier
"""
function sort_edges(graph::Graph)
    sorted_dict = merge_sort_dict(collect(graph.edges))
    return OrderedDict(sorted_dict)
end