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