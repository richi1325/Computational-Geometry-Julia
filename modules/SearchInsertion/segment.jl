include("util.jl")
using LinearAlgebra

function find_intersect(s1::Segment, s2::Segment)
    v1 = s1.b - s1.a
    v2 = s2.a - s2.b
    b = s2.a - s1.a
    A = hcat(v1,v2)
    try
        x = inv(A) * b
        if !all(0 .<= x .<= 1)
            return "nointersect", nothing
        end
        inters = x[1] * v1 + s1.a
        if x[1] == 1 || x[2] == 1 || x[1] == 0 || x[2] == 0
            return "vertex", inters
        end
        return "intersect", inters
    catch e
        return "parallel",nothing
    end
end

function find_intersect(seg::Segment, pol::Polygon)
    v1 = seg.b - seg.a
    # Get the normal
    v2 = pol.head.prev.value - pol.head.value
    v3 = pol.head.next.value - pol.head.value
    n = cross(v2,v3)
    # Get real for vectorial's line form
    t = dot(pol.head.value - seg.a, n) / dot(v1,n)
    if 0 > t ||  t > 1
        return "outside",nothing
    end
    point = seg.a + t*v1
    axis = argmax(abs.(n))
    pol2d = Polygon([deleteat!(v,axis) for v in flatpolygon(pol)]...)
    point2d = copy(point)
    deleteat!(point2d, axis)
    areasign = []
    cur = pol2d.head
    while true
        push!(areasign, getarea(cur.value,cur.next.value, point2d))
        cur = cur.next
        if cur == pol2d.head
            break
        end
    end
    positives = sum(areasign .> 0)
    negatives = sum(areasign .< 0)
    if positives > 0 && negatives > 0
        return "outside",nothing
    end
    code = ""
    if t == 0
        code *= "first_"
    end
    if t == 1
        code *= "second_"
    end
    if positives == 3 || negatives == 3
        code *= "inside"
    end
    if positives == 1 || negatives == 1
        code *= "vertex"
    end
    if positives == 2  || negatives == 2
        code *= "edge"
    end
    return code, point
end

function intersects(seg::Segment, pol::Polygon)
    vals = []
    a = seg.a
    b = seg.b
    cur = pol.head
    while true
        vol = getvolume(b, cur.value, cur.next.value, a)
        push!(vals, vol)
        cur = cur.next
        if cur == pol.head
            break
        end
    end
    positives = sum(vals .> 0)
    negatives = sum(vals .< 0)
    if positives == 3 || negatives == 3
        return "inside"
    end
    if positives > 0 && negatives > 0
        return "outside"
    end
    if positives == 1 || negatives == 1
        return "vertex"
    end
    if positives == 2  || negatives == 2
        return "edge"
    end
end

function isinside(p::Vector, pol::Polygon)
    cur = pol.head
    rcross = 0
    lcross = 0
    while true
        x = nothing
        p0 = cur.prev.value
        p1 = cur.value
        if p1 == p
            return "vertex"
        end
        rstrad = (p1[2] > p[2]) != (p0[2] > p[2])
        lstrad = (p1[2] < p[2]) != (p0[2] < p[2])
        cur = cur.next
        if cur == pol.head
            break
        end
        if !rstrad && !lstrad
            continue
        end
        if p1[1] == p0[1]
            x = p1[1]
        else
            m = (p1[2]-p0[2])/(p1[1]-p0[1])
            x = p[2]/m - p1[2]/m + p1[1]
        end
        if rstrad && (x > p[1])
            rcross += 1
        end
        if lstrad && (x < p[1])
            lcross += 1
        end
    end
    if rcross%2 != lcross%2
        return "edge"
    end
    if rcross%2 == 1
        return "inside"
    end
    return "outside"
end

function isinside(q::Vector, hedron::Polyhedron)
    faces = hedron.faces
    xs = [elem[1] for elem in hedron.vertices]
    ys = [elem[2] for elem in hedron.vertices]
    zs = [elem[3] for elem in hedron.vertices]
    pmin = [min(xs...),min(ys...),min(zs...)]
    pmax = [max(xs...),max(ys...),max(zs...)]
    if sum(q .>= pmin) < 3 || sum(q .<= pmax) < 3
        return "outside"
    end
    D = sum((pmin-pmax) .^ 2)^0.5
    R = ceil(D)+1
    while true
        cross = 0
        degen = false
        phi,theta = pi*rand(),2*pi*rand()
        ray = R .* [sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi)]
        r = q + ray
        for face in hedron.faces
            code, inter = find_intersect(Segment(q,r),face)
            if code=="vertex" || code=="edge"
                degen = true
                break
            end
            if code=="first_vertex" || code=="first_edge" || code=="first_inside"
                return code
            end
            if code != "inside"
                cross += 1
            end
        end
        if degen
            continue
        end
        if cross%2 == 1
            return "inside"
        else
            return "outside"
        end
    end
end
