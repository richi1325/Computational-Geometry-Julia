include("util.jl")
include("segment.jl")

function seg2seg(s1, s2, expected)
    obt = find_intersect(s1,s2)
    if obt == expected
        println("seg2seg Test passed")
    else
        println("seg2seg failed exp:$(expected) obt:$(obt)")
    end
end

# Not intersects
s1 = Segment([0,0],[4,4])
s2 = Segment([1,0],[5,4])
seg2seg(s1,s2,nothing)

s1 = Segment([0,0],[4,4])
s2 = Segment([0,4],[4,0])
seg2seg(s1,s2,[2.0,2.0])

s1 = Segment([0,0],[4,4])
s2 = Segment([4,4],[4,0])
seg2seg(s1,s2,[4.0,4.0])


