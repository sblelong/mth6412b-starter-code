module STSP

using Plots
using LinearAlgebra

import Base.show

"""
	name(n::Any)

Renvoie le nom de l'objet passé en argument."""
function name(n::Any)
    return nothing
end

include("phase1/node.jl")
include("phase1/edge.jl")
include("phase1/graph.jl")

include("phase1/read_stsp.jl")

include("phase2/connected.jl")
include("phase2/kruskal.jl")

include("phase3/priority_queue.jl")
include("phase3/prim.jl")

include("phase4/rsl.jl")
include("phase4/exploration.jl")
include("phase4/benchmark.jl")
include("phase4/hk.jl")
include("phase4/traverse.jl")

end