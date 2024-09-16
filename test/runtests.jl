using Test
include("../src/phase1/node.jl")
#include("../src/phase1/edge.jl")
include("../src/phase1/graph.jl")

@testset "fake tests" begin
  node1 = Node("Joe", 3.14)
  node2 = Node("Steve", exp(1))
  node3 = Node("Jill", 4.12)
  G = Graph("Ick", [node1, node2, node3])
  add_edge(G,node1,node2)
  add_edge(G,node2,node3)
  show(G)

end