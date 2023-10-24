using Test

@testset "fake tests" begin
  @test 1==1

  @test true * false != true * true

  @test Bool(true + false) == true
  
end