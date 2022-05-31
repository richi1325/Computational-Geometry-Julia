include("util.jl")
include("segment.jl")

function point_inside_pol(point,pol,expected)
    test = "point inside polygon"
    obt = isinside(point,pol)
    if obt == expected
        println("$(test) Test passed")
    else
        println("$(test) failed exp:$(expected) obt:$(obt)")
    end
end

function point_inside_hedron(point,hedron,expected)
    test = "point inside polyhedron"
    obt = isinside(point,hedron)
    if obt == expected
        println("$(test) Test passed")
    else
        println("$(test) failed exp:$(expected) obt:$(obt)")
    end
end

pol = Polygon([4,4],[8,4],[8,8],[12,4],[20,12],[4,12])

point = [6,6]
point_inside_pol(point,pol,"inside")
point = [2,6]
point_inside_pol(point,pol,"outside")
point = [4,4]
point_inside_pol(point,pol,"vertex")
point = [8,6]
point_inside_pol(point,pol,"edge")

v1 = [0,0,0]
v2 = [1,0,0]
v3 = [0,1,0]
v4 = [0,0,1]
hedron = Polyhedron((v1,v2,v3,v4),[1,2,3],[1,2,4],[1,3,4],[2,3,4])

point = [0,0,0]
point_inside_hedron(point,hedron,"first_vertex")
point = [0,0.5,0]
point_inside_hedron(point,hedron,"first_edge")
point = [-1,-1,-1]
point_inside_hedron(point,hedron,"outside")
point = [0.25,0.25,0.25]
point_inside_hedron(point,hedron,"inside")
point = [0.3,0.3,0.3]
point_inside_hedron(point,hedron,"inside")
