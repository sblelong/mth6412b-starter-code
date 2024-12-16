using Plots

include("bin/tools.jl")

export reconstruct_and_display, unshred_rsl, unshred_hk

images = ["abstract-light-painting", "alaska-railroad", "blue-hour-paris", "lower-kananaskis-lake", "marlet2-radio-board", "nikos-cat", "pizza-food-wallpaper", "the-enchanted-garden", "tokyo-skytree-aerial"]

function reconstruct_and_display(image_name::String, tour::Vector{Int64}, cost::Float64, alg::String)
    shuffled_picture = load("images/shuffled/" * image_name * ".png")
    original_picture = load("images/original/" * image_name * ".png")
    reconstructed_picture = shuffled_picture[:, tour[2:end]]
    pr = plot(reconstructed_picture, axis=nothing, title="Reconstitué")
    po = plot(original_picture, axis=nothing, title="Original")
    plot!(pr, po, layout=(1, 2), xaxis=false, yaxis=false, plot_title="Coût de la tournée ($alg) : $cost")
end

function unshred_rsl(image_name::String)
    G = read_stsp("tsp/instances/" * image_name * ".tsp")
    # Trouver la meilleure racine
    best_cost = Inf
    best_start = 0
    best_tour = nothing
    for node in keys(G.nodes)
        try
            if node != "1"
                cost, tour = rsl(G; root_id=node, unshred_mode=true)
                if cost < best_cost
                    best_start = node
                    best_cost = cost
                    best_tour = tour
                end
            end
        catch
            continue
        end
    end
    tour_int = reorder_tour([parse(Int, node) - 1 for node in best_tour])

    return tour_int, best_cost
end

function unshred_hk(image_name::String; start_node_id::Union{Nothing,String}=nothing, mst_method="prim", τ::Float64=0.4, nesterov_weight::Union{Float64,Nothing}=0.7, one_tree_heuristic::Bool=true)
    G = read_stsp("tsp/instances/" * image_name * ".tsp")
    cost, tour = hk(G; start_node_id, mst_method, τ, nesterov_weight, one_tree_heuristic)
    tour_int = reorder_tour([parse(Int, node) - 1 for node in tour])

    return tour_int, cost
end

#= function compute_picture(picture_name::String, filename::String)
    G = read_stsp("tsp/instances/" * picture_name * ".tsp")
    cost, tour = rsl(G)
    tour_int = [parse(Int, node) for node in tour]

    tour_filename = "results/tours/" * picture_name * "_rsl.tour"
    write_tour(tour_filename, tour_int, cost)

    reconstruct_picture(tour_filename, "images/shuffled/" * picture_name * ".png", "results/reconstructed/" * filename)

    return cost, tour_int
end =#