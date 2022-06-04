include("_util.jl")
include("_types.jl")
include("extremal.jl")

pol = [Polygon([1,1],[3,1],[4,3],[2,4],[0,3]),
    Polygon([1,1],[3,1],[4,3],[2,4],[0,3]),
    Polygon([4,2],[6,1],[8,4],[9,7],[6,6],[4,4]),
    Polygon([2,6],[-4,6],[-4,2],[-2,-2],[4,2])
    ]
us = [
    [0,1],
    [1,0],
    [1,1],
    [0,-1]
    ]
exp = [
    [2,4],
    [4,3],
    [9,7],
    [-2,-2]
    ]
f = (p,u)->find_extremal(p,u)
for (p,u,e) in zip(pol,us,exp)
    test(f,"extremal point",[p,u],e)
end
