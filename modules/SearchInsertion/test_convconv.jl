include("util.jl")
include("intersection.jl")

function convex_intersects_test(p,q,expected)
    obt = flatpolygon(convpol_intersect(p,q))
    if obt == expected
        println("seg2tri Test passed")
    else
        println("seg2tri failed exp:$(expected) obt:$(obt)")
    end
end


p = Polygon([0,0],[2,0],[2,2],[0,2])
q = Polygon([1,1],[3,1],[3,3],[1,3])
convex_intersects_test(p,q, [[2.0,1.0],[2.0,2.0],[1.0,2.0],[1.0,1.0]])