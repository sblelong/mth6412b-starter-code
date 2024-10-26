using STSP,Test

@testset "Lecture Notes Graph" begin
  nodes = Node{Int64}[]
  for letter in 'a':'i'
    push!(nodes,Node(string(letter),0))
  end

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 4 ))
  push!(edges, Edge("b", "c", 8 ))
  push!(edges, Edge("c", "d", 7 ))
  push!(edges, Edge("d", "e", 9 ))
  push!(edges, Edge( "e", "f", 10))
  push!(edges, Edge( "d", "f", 14))
  push!(edges, Edge("f", "c", 4 ))
  push!(edges, Edge("f", "g", 2 ))
  push!(edges, Edge("c", "i", 2 ))
  push!(edges, Edge("g", "i", 6 ))
  push!(edges, Edge("h", "i", 7 ))
  push!(edges, Edge("h", "g", 1 ))
  push!(edges, Edge( "h", "b", 11))
  push!(edges, Edge("h", "a", 8 ))

  G = Graph("KruskalLectureNotesTest", nodes, edges)

  cost, edges = kruskal(G)
  @test cost == 37
  @test edges[1].data == 1
  @test edges[end].data == 9

  cost, edges = prim(G, "a")

  @test cost == 37
  @test edges[1].data == 4
  @test edges[end].data == 9

  edges = Edge{Int64}[]
  push!(edges, Edge("a", "b", 4 ))
  push!(edges, Edge("c", "d", 7 ))
  push!(edges, Edge("d", "e", 9 ))
  push!(edges, Edge( "e", "f", 10))
  push!(edges, Edge( "d", "f", 14))
  push!(edges, Edge("f", "c", 4 ))
  push!(edges, Edge("f", "g", 2 ))
  push!(edges, Edge("c", "i", 2 ))
  push!(edges, Edge("g", "i", 6 ))
  push!(edges, Edge( "h", "b", 11))
  push!(edges, Edge("h", "a", 8 ))

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
