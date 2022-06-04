include("_util.jl")
include("_types.jl")
include("inside.jl")

pol = Polygon([4,4],[8,4],[8,8],[12,4],[20,12],[4,12])

points = [[6,6],
    [2,6],
    [4,4],
    [8,6]]
exp = ["inside",
    "outside",
    "vertex",
    "edge"]
f = (p,po) -> isinside(p,po)
for (p,e) in zip(points,exp)
    test(f,"point inside polygon",[p,pol],e)
end

v1 = [0,0,0]
v2 = [1,0,0]
v3 = [0,1,0]
v4 = [0,0,1]
hedron = Polyhedron((v1,v2,v3,v4),[1,2,3],[1,2,4],[1,3,4],[2,3,4])
points = [[0,0,0],
    [0,0.5,0],
    [-1,-1,-1],
    [0.25,0.25,0.25],
    [0.3,0.3,0.3]]
exp = ["first_vertex",
    "first_edge",
    "outside",
    "inside",
    "inside"]
f = (p,hed) -> isinside(p,hed)
for (p,e) in zip(points,exp)
    test(f,"point inside polyhedron",[p,hedron],e)
end