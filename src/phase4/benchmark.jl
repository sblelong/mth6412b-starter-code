export find_edge, tour_cost, get_optimal, plot_tour

using JSON

function find_edge(G::Graph{T,U}, node1_id::String, node2_id::String)::Edge where {T,U}
    for edge in G.adjacency[node1_id]
        if edge.node2_id == node2_id || edge.node1_id == node2_id
            return edge
        end
    end
    graph_name = G.name
    error("No edge connecting $node1_id and $node2_id in graph $graph_name")
end

function tour_cost(G::Graph{T,U}, tour::Vector{String})::U where {T,U}
    total_cost = 0
    for k in 1:length(tour)-1
        edge = find_edge(G, tour[k], tour[k+1])
        total_cost += edge.data
    end
    return total_cost
end

function compare_tour(G::Graph{T,U}, optimal_tour::Vector{String}, tour::Vector{String})::Float32 where {T,U}
    t_cost = tour_cost(G, tour)
    opt_cost = tour_cost(G, optimal_tour)
    return t_cost / opt_cost
end

function get_optimal(filename::String)::Float32
    optimals = JSON.parsefile("instances/stsp/optimals.json")
    haskey(optimals, filename) && return optimals[filename]
    error("Instance $filename couldn't be found while retrieving known optimal")
end

function plot_tour(G::Graph{T,U}, tour::Vector{String}) where {T,U}
    edges = Edge{U}[]
    for k in 1:length(tour)-1
        push!(edges, find_edge(G, tour[k], tour[k+1]))
    end
    tour_graph = Graph("", collect(values(G.nodes)), edges)
    plot_graph(tour_graph)
end