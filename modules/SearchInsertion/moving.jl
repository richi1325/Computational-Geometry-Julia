include("_types.jl")
include("_util.jl")
include("intersection.jl")
include("inside.jl")
import LazySets
const ls = LazySets

function get_visibility_graph(origin,dest,pols)
    points = []
    npol = length(pols)
    push!(points,(origin,npol+1))
    push!(points,(dest,npol+2))
    for (i,p) in enumerate(pols)
        points = append!(points,flatpolygon_vertex(p,i))
    end
    graph = Dict()
    for (p,_) in points
        graph[p.value] = []
    end
    for i in 1:length(points)
        for j in (i+1):length(points)
            x,p1 = points[i]
            y,p2 = points[j]
            if p1 == p2
                if ((x.next == y) || (x.prev == y))
                    push!(graph[x.value],(y.value,dist(y.value,x.value)))
                    push!(graph[y.value],(x.value,dist(y.value,x.value)))
                end
                continue
            end
            s1 = Segment(x.value,y.value)
            is_visible = true
            for (p,_) in points[3:length(points)]
                if (p==x) || (p.next==x)
                    continue
                end
                s2 = Segment(p.value,p.next.value)
                code, _ = find_intersect(s1,s2)
                if code == "intersect" || code =="vertex"
                    is_visible = false
                    break
                end
            end
            if is_visible
                push!(graph[x.value],(y.value,dist(y.value,x.value)))
                push!(graph[y.value],(x.value,dist(y.value,x.value)))
            end
        end
    end
    return graph
end

function minkowski_sum(p::Polygon,q::Polygon)
    cp = p.head
    points = Set()
    while true
        cq = q.head
        while true
            push!(points,cq.value+cp.value)
            cq = cq.next
            if cq == q.head
                break
            end
        end
        cp = cp.next
        if cp == p.head
            break
        end
    end
    points = map(x->Float64[x[1],x[2]],collect(points))
    hull = ls.convex_hull(collect(points))
    return Polygon(hull...)
end

function union_pols(p::Polygon,q::Polygon)
    cq = q.head
    while true
        if isinside(cq.value,p)
            s1 = Segment()
        end
        cq = cq.next
        if cq == q.head
            break
        end
    end
end

function dijkstra(vg,origin,dest)
    or = origin.value
    de = dest.value
    dist = Dict(zip(collect(keys(vg)),repeat(Any[Inf],length(vg))))
    prev = Dict(zip(collect(keys(vg)),repeat(Any[nothing],length(vg))))
    dist[or] = 0
    Q = collect(keys(vg))
    while !isempty(Q)
        u = reduce((x, y) -> dist[x] < dist[y] ? x : y, Q)
        filter!((x,)->x!=u,Q)
        for (v,d) in vg[u]
            alt = dist[u] + d
            if alt < dist[v]
                dist[v] = alt
                prev[v] = u
            end
        end
    end
    cur = de
    path = []
    while true
        push!(path,cur)
        if cur == or
            break
        end
        cur = prev[cur]
    end
    return reverse!(path)
end