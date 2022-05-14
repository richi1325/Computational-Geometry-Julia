include("util.jl")
using LinearAlgebra

function find_intersect(s1::Segment, s2::Segment)
    v1 = s1.b - s1.a
    v2 = s2.a - s2.b
    b = s2.a - s1.a
    A = hcat(v1,v2)
    x = inv(A) * b
    if 0 .<= x .<= 1
        return x[1] * v1 + s1.a
    end
    return nothing
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
        return nothing
    end
    point = seg.a + t*v1
    axis = argmax(n)
    pol2d = Polygon([deleteat!(v,axis) for v in flatpolygon(pol)]...)
    point2d = copy(point)
    deleteat!(point2d, axis)
    areasign = []
    cur = pol2d.head
    while true
        push!(areasign, getarea(cur.value,cur.next.value, point2d.value))
        cur = cur.next
        if cur == pol2d.head
            break
        end
    end
    if all(areasign .>= 0) || all(areasign .<= 0)
        return point
    end
    return nothing
end

function intersects(seg::Segment, pol::Polygon)
    vals = []
    a = seg.a
    b = seg.b
    cur = pol.head
    while true
        vol = getvolume(a, cur.value, cur.next.value, b)
        push!(vals, area)
        cur = cur.next
        if cur == pol.head
            break
        end
    end
    return vals
    if all(vals .>= 0) || all(vals .<= 0)
        return true
    end
    return false
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
        rstrad = (p1[1] > p[1]) != (p0[1] > p[1])
        lstrad = (p1[1] < p[1]) != (p0[1] < p[1])
        if !(rstrad || lstrad)
            continue
        end
        if p1[0] == p0[0]
            x = p1[0]
        else
            m = (p1[1]-p0[1])/(p1[0]-p0[0])
            x = p[1]/m + p1[1]/m + p1[0]
        end
        if rstrad && (x > 0)
            rcross += 1
        end
        if lstrad && (x < 0)
            lcross += 1
        end
        cur = cur.next
        if cur == pol.head
            break
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