using Test
include("../src/phase1/node.jl")
include("../src/phase1/edge.jl")
include("../src/phase1/graph.jl")

include("../src/phase1/read_stsp.jl")

@testset "Edge Reader Test" begin

  folder_path = "instances/stsp"
  instances = readdir(folder_path)

  for instance in instances
    file_path = joinpath(folder_path, instance)
    header = read_header(file_path)
    edges = read_edges(header,file_path)

    @test all(elem -> typeof(elem) <: Tuple{Int, Int, Int} && length(elem) == 3, edges)

  end
end

folder_path = "instances/stsp"
instances = readdir(folder_path)
instance = rand(instances)

filename = joinpath(folder_path,instance)

header = read_header(filename)
nodes_dict = read_nodes(header, filename)
edges_list = read_edges(header, filename)
dim = parse(Int, header["DIMENSION"])

G_name = replace(instance, ".tsp" => "")
T = Vector{Float64}

G = Graph(G_name, Node{T}[], Edge{T,Int}[])
for k = 1:dim
  if isempty(nodes_dict)
    add_node!(G, Node(string(k),[NaN,NaN]))
  else
    add_node!(G, Node(string(k), nodes_dict[k]))
  end
end

for edge in edges_list
  add_edge(G,G.nodes[edge[1]],G.nodes[edge[2]],edge[3])
end

show(G)
