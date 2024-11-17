using STSP, Test

@testset "Lecture Notes Graph" begin
  nodes = Node{Int64}[]
  for letter in 'a':'i'
    push!(nodes, Node(string(letter), 0))
  end

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 4))
  push!(edges, Edge("b", "c", 8))
  push!(edges, Edge("c", "d", 7))
  push!(edges, Edge("d", "e", 9))
  push!(edges, Edge("e", "f", 10))
  push!(edges, Edge("d", "f", 14))
  push!(edges, Edge("f", "c", 4))
  push!(edges, Edge("f", "g", 2))
  push!(edges, Edge("c", "i", 2))
  push!(edges, Edge("g", "i", 6))
  push!(edges, Edge("h", "i", 7))
  push!(edges, Edge("h", "g", 1))
  push!(edges, Edge("h", "b", 11))
  push!(edges, Edge("h", "a", 8))

  G = Graph("KruskalLectureNotesTest", nodes, edges)

  cost, edges = kruskal(G)
  @test cost == 37
  @test edges[1].data == 1
  @test edges[end].data == 9

  cost, edges, forest = prim(G, "a", return_rsl=true)

  @test cost == 37
  @test edges[1].data == 4
  @test edges[end].data == 9

  edge_cost = 0
  for edge in edges
    edge_cost += edge.data
  end
  @test edge_cost == cost

  cost, edges = one_tree(G, node_id="a", method="Prim", root_id="b")
  @test cost == 45

  p = Dict{String,Int64}("a" => 2, "c" => 6, "f" => 1, "d" => 3)
  cost, edges = one_tree(G, node_id="a", method="Prim", root_id="b", p=p)
  @test cost == 53

  cost, edges = one_tree(G, node_id="a", method="Kruskal")
  @test cost == 45

  p = Dict{String,Int64}("a" => 2, "c" => 6, "f" => 1, "d" => 3)
  cost, edges = one_tree(G, node_id="a", method="Kruskal", p=p)
  @test cost == 53

  edges = Edge{Float32}[]
  push!(edges, Edge("a", "b", Float32(4)))
  push!(edges, Edge("b", "c", Float32(8)))
  push!(edges, Edge("c", "d", Float32(7)))
  push!(edges, Edge("d", "e", Float32(9)))
  push!(edges, Edge("e", "f", Float32(10)))
  push!(edges, Edge("d", "f", Float32(14)))
  push!(edges, Edge("f", "c", Float32(4)))
  push!(edges, Edge("f", "g", Float32(2)))
  push!(edges, Edge("c", "i", Float32(2)))
  push!(edges, Edge("g", "i", Float32(6)))
  push!(edges, Edge("h", "i", Float32(7)))
  push!(edges, Edge("h", "g", Float32(1)))
  push!(edges, Edge("h", "b", Float32(11)))
  push!(edges, Edge("h", "a", Float32(8)))

  G = Graph("KruskalLectureNotesTest-Float32", nodes, edges)

  cost, edges = kruskal(G)
  @test typeof(cost) == Float32
  @test cost == 37

  cost, edges = prim(G, "a")

  @test typeof(cost) == Float32
  @test cost == 37

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 4))
  push!(edges, Edge("c", "d", 7))
  push!(edges, Edge("d", "e", 9))
  push!(edges, Edge("e", "f", 10))
  push!(edges, Edge("d", "f", 14))
  push!(edges, Edge("f", "c", 4))
  push!(edges, Edge("f", "g", 2))
  push!(edges, Edge("c", "i", 2))
  push!(edges, Edge("g", "i", 6))
  push!(edges, Edge("h", "b", 11))
  push!(edges, Edge("h", "a", 8))

  G = Graph("NonConnectedKruskalLectureNotesTest", nodes, edges)
  let err = nothing
    try
      kruskal(G)
    catch err
    end
    @test err isa Exception
    @test sprint(showerror, err) == "Kruskal: Graph is not connected."
  end

  let err = nothing
    try
      prim(G)
    catch err
    end
    @test err isa Exception
    @test sprint(showerror, err) == "Prim: Graph is not connected."
  end

end

@testset "AccelerationHeuristics" begin
  # A Tree initialized with size mode as empty rank, and vice-versa.
  size_tree = Tree("3", 1)
  explicit_size_tree = Tree("3", 1, mode="size")
  rank_tree = Tree("3", 0, mode="rank")

  @test size_tree.size == explicit_size_tree.size
  @test isnothing(size_tree.rank)
  @test isnothing(rank_tree.size)

  # Merge based on the rank
  nodes = Node{Int64}[]
  push!(nodes, Node("a", 0))
  push!(nodes, Node("b", 0))
  push!(nodes, Node("c", 0))

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 1))
  push!(edges, Edge("b", "c", 1))

  G = Graph("TestGraph", nodes, edges)
  F = Forest(G, mode="rank")
  # A merge based on the rank should yield the following results :
  # 1. When merging 2 nodes with the same rank, one should increase
  size_bef_merge = length(F.trees["b"].child_ids)
  merge!(F, "a", "b", mode="rank")
  # The rank of b should be 1, and a 0
  @test F.trees["a"].parent_id == "b"
  @test F.trees["b"].rank == 1
  @test F.trees["a"].rank == 0
  @test length(F.trees["b"].child_ids) == size_bef_merge + length(F.trees["a"].child_ids) + 1

  size_bef_merge = length(F.trees["b"].child_ids)
  merge!(F, "b", "c", mode="rank")
  # Ranks should not change
  @test F.trees["c"].parent_id == "b"
  @test F.trees["b"].rank == 1
  @test F.trees["c"].rank == 0
  @test length(F.trees["b"].child_ids) == size_bef_merge + length(F.trees["c"].child_ids) + 1

  # Kruskal with rank
  nodes = Node{Int64}[]
  for letter in 'a':'i'
    push!(nodes, Node(string(letter), 0))
  end

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 4))
  push!(edges, Edge("b", "c", 8))
  push!(edges, Edge("c", "d", 7))
  push!(edges, Edge("d", "e", 9))
  push!(edges, Edge("e", "f", 10))
  push!(edges, Edge("d", "f", 14))
  push!(edges, Edge("f", "c", 4))
  push!(edges, Edge("f", "g", 2))
  push!(edges, Edge("c", "i", 2))
  push!(edges, Edge("g", "i", 6))
  push!(edges, Edge("h", "i", 7))
  push!(edges, Edge("h", "g", 1))
  push!(edges, Edge("h", "b", 11))
  push!(edges, Edge("h", "a", 8))

  G = Graph("KruskalLectureNotesTest", nodes, edges)

  cost, edges = kruskal(G, mode="rank")

  @test cost == 37
  @test edges[1].data == 1
  @test edges[end].data == 9
end

@testset "RSL" begin

  # Vérifier qu'une tournée est bien constituée d'autant de noeuds que le graphe
  nodes = Node{Int64}[]
  edges = Edge{Int64}[]
  for k in 1:8
    push!(nodes, Node(string(k), 0))
  end

  for k in 1:7
    push!(edges, Edge(string(k), string(k + 1), k + 2))
  end

  G = Graph("RSL test", nodes, edges)

  cost, tour = rsl(G)
  @test length(tour) == length(G.nodes)
  for k in 1:8
    @test string(k) in tour
  end

end

@testset "Helsgaun" begin
  nodes = Node{Int64}[]
  for letter in 'a':'i'
    push!(nodes, Node(string(letter), 0))
  end

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 4))
  push!(edges, Edge("b", "c", 8))
  push!(edges, Edge("c", "d", 7))
  push!(edges, Edge("d", "e", 9))
  push!(edges, Edge("e", "f", 10))
  push!(edges, Edge("d", "f", 14))
  push!(edges, Edge("f", "c", 4))
  push!(edges, Edge("f", "g", 2))
  push!(edges, Edge("c", "i", 2))
  push!(edges, Edge("g", "i", 6))
  push!(edges, Edge("h", "i", 7))
  push!(edges, Edge("h", "g", 1))
  push!(edges, Edge("h", "b", 11))
  push!(edges, Edge("h", "a", 8))

  G = Graph("KruskalLectureNotesTest", nodes, edges)
  cost, edges = hk(G, start_node_id = "a")
  @test cost == Float64(45)
  cost, edges = hk(G, start_node_id = "a", method = "Kruskal")
  @test cost == Float64(45)
  """
  G = read_stsp("../instances/stsp/dantzig42.tsp") 
  cost, edges = hk(G, nothing)
  println(cost)
  """
end