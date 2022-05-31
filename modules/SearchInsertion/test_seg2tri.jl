include("util.jl")
include("segment.jl")

function seg2tri(s,pol,expected)
    obt = find_intersect(s1,pol)[1]
    if obt == expected
        println("seg2tri Test passed")
    else
        println("seg2tri failed exp:$(expected) obt:$(obt)")
    end
end

function seg_intersects(s, pol, expected)
    obt = intersects(s1,pol)
    if obt == expected
        println("seg_intersects Test passed")
    else
        println("seg_intersects failed exp:$(expected) obt:$(obt)")
    end
end

pol = Polygon([2,0,0],[0,2,0],[0,0,2])

s1 = Segment([0,0,0],[4,4,4])
seg2tri(s1,pol,"inside")
s1 = Segment([0,0,0],[-4,-4,-4])
seg2tri(s1,pol,"outside")
s1 = Segment([0,0,0],[2,-1,0])
seg2tri(s1,pol,"outside")
s1 = Segment([0,0,0],[4,0,0])
seg2tri(s1,pol,"vertex")
s1 = Segment([0,0,0],[2,2,0])
seg2tri(s1,pol,"edge")

s1 = Segment([0,0,0],[4,4,4])
seg_intersects(s1,pol,"inside")
s1 = Segment([0,0,0],[-4,-4,-4])
seg_intersects(s1,pol,"inside")
s1 = Segment([0,0,0],[2,-1,0])
seg_intersects(s1,pol,"outside")
s1 = Segment([0,0,0],[4,0,0])
seg_intersects(s1,pol,"vertex")
s1 = Segment([0,0,0],[2,2,0])
seg_intersects(s1,pol,"edge")