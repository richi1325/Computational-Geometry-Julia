include("_util.jl")
include("_types.jl")
include("intersection.jl")

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
