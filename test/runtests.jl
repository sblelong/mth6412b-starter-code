using STSP,Test

@testset "Edge Reader Test" begin

  folder_path = "../instances/stsp"
  instances = readdir(folder_path)

  for instance in instances
    file_path = joinpath(folder_path, instance)
    header = read_header(file_path)
    edges = read_edges(header,file_path)
    @test eltype(getfield.(edges, :name)) <: String
    @test eltype(getfield.(edges, :node1_id)) <: String
    @test eltype(getfield.(edges, :node2_id)) <: String
    @test eltype(getfield.(edges, :data)) <: Int
  end
end

@testset "Node Reader Test" begin

  folder_path = "../instances/stsp"
  instances = readdir(folder_path)

  for instance in instances
    file_path = joinpath(folder_path, instance)
    header = read_header(file_path)
    nodes = read_nodes(header,file_path)
    @test eltype(getfield.(nodes, :name)) <: String
    if header["DISPLAY_DATA_TYPE"] in ["COORDS_DISPLAY", "TWOD_DISPLAY"]
      @test eltype(getfield.(nodes, :data)) <: Vector{Float64}
    else
      @test eltype(getfield.(nodes, :data)) <: Float64
    end
  end
end

@testset "Graph Reader Test" begin

  folder_path = "../instances/stsp"
  instances = readdir(folder_path)

  for instance in instances
    file_path = joinpath(folder_path, instance)
    header = read_header(file_path)
    dim = parse(Int, header["DIMENSION"])
    graph = read_stsp(file_path, quiet = true)
    if header["DISPLAY_DATA_TYPE"] in ["COORDS_DISPLAY", "TWOD_DISPLAY"]
      @test typeof(graph.nodes) <: Dict{String, Node{Vector{Float64}}}
    end
    @test length(nodes(graph)) == dim
    @test typeof(graph.edges) <: Dict{String, Edge{Int64}}

    @test length(graph.adjacency) == dim #each node should be connected to at least one other node.
  end
end
