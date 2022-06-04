include("_util.jl")
include("_types.jl")
include("intersection.jl")

# intersects
pol = Polygon([2,0,0],[0,2,0],[0,0,2])
segs = [Segment([0,0,0],[4,4,4]),
    Segment([0,0,0],[-4,-4,-4]),
    Segment([0,0,0],[2,-1,0]),
    Segment([0,0,0],[4,0,0]),
    Segment([0,0,0],[2,2,0])
    ]
exp = ["inside",
    "inside",
    "outside",
    "vertex",
    "edge"
    ]
f = (s,p) -> intersects(s,p)
for (s,e) in zip(segs,exp)
    test(f, "intersects seg2tri", [s,pol], e)
end

# find_intersects seg2seg
segs1 = [Segment([0,0],[4,4]),
    Segment([0,0],[4,4]),
    Segment([0,0],[4,4])
    ]
segs2 = [Segment([1,0],[5,4]),
    Segment([0,4],[4,0]),
    Segment([4,4],[4,0])
    ]
exp = [nothing,
    [2.0,2.0],
    [4.0,4.0],
    ]
f = (s_1,s_2)-> find_intersect(s_1,s_2)[2]
for (s1,s2,e) in  zip(segs1,segs2,exp)
    test(f, "find intersect seg2seg", [s1,s2], e)
end

p = Polygon([0,0],[2,0],[2,2],[0,2])
q = Polygon([1,1],[3,1],[3,3],[1,3])
exp = [[2.0,1.0],[2.0,2.0],[1.0,2.0],[1.0,1.0]]
f = (p1,p2) -> flatpolygon(find_intersect(p1,p2))
test(f, "find intersect conv2conv", [p,q],exp)