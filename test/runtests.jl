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
  merge!(F, "a", "b", mode="rank")
  # The rank of b should be 1, and a 0
  @test F.trees["a"].parent_id == "b"
  @test F.trees["b"].rank == 1
  @test F.trees["a"].rank == 0

  merge!(F, "b", "c", mode="rank")
  # Ranks should not change
  @test F.trees["c"].parent_id == "b"
  @test F.trees["b"].rank == 1
  @test F.trees["c"].rank == 0

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