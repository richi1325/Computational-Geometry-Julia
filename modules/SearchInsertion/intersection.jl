include("_types.jl")
include("_util.jl")
import LinearAlgebra
import DataStructures
const la = LinearAlgebra
const ds = DataStructures

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
        if xor(x[1] == 1, x[2] == 1, x[1] == 0, x[2] == 0 )
            return "vertex", inters
        end
        if x[1] == 1 || x[2] == 1 || x[1] == 0 || x[2] == 0
            return "adjacent", inters
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
    n = la.cross(v2,v3)
    # Get real for vectorial's line form
    t = la.dot(pol.head.value - seg.a, n) / la.dot(v1,n)
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

function find_intersect(P::Polygon, Q::Polygon)
    inflag = "unknown"
    first_point = true
    p0 = nothing
    n, m = P.n, Q.n
    curA = P.head
    curB = Q.head
    a1, b1 = nothing, nothing
    a_adv, b_adv, a, b = 0,0,0,0
    interpol = []
    while true
        a1 = (a+n-1)%n
        b1 = (b+m-1)%m
        A = curA.value - curA.prev.value
        B = curB.value - curB.prev.value
        cross = getarea([0,0], A, B)
        aHB =  getarea(curB.prev.value,curB.value,curA.value)
        bHA =  getarea(curA.prev.value,curA.value,curB.value)
        s1 = Segment(curA.prev.value,curA.value)
        s2 = Segment(curB.prev.value,curB.value)
        code, inters = find_intersect(s1,s2)
        if code == "intersect" || code == "vertex"
            if (inflag == "unknown") && first_point
                a_adv = 0 
                b_adv = 0
                first_point = false
                p0 = inters
            end
            inflag = inout(inters, inflag, aHB, bHA)
            push!(interpol, inters)
        end
        ap = nothing
        if cross >= 0
            if bHA > 0
                a,a_adv,ap = advance(a, a_adv, n, inflag=="Pin", curA.value)
                curA = curA.next
            else
                b,b_adv,ap = advance(b, b_adv, m, inflag=="Qin", curB.value)
                curB = curB.next
            end
        else
            if aHB > 0
                b,b_adv,ap = advance(b, b_adv, m, inflag=="Qin", curB.value)
                curB = curB.next
            else
                a,a_adv,ap = advance(a, a_adv, n, inflag=="Pin", curA.value)
                curA = curA.next
            end
        end
        if ap != nothing
            push!(interpol,ap)
        end
        # break condition
        if !((a_adv < n) || (b_adv < m)) && (a_adv < 2*n) && (b_adv < 2*m)
            break
        end
    end
    if inflag == "unknown"
        return nothing
    end
    return Polygon(interpol...)
end

function find_intersects(segs...)
    Q = AVLTree()
    L = AVLTree()
    for seg in segs
        push!(Q, Event(seg,1))
        push!(Q, Event(seg,2))
    end
    while length(Q) > 0
        event = Q[1]
        delete!(Q, Q[1])
        if event.typ == 1
            push!(L, event.seg)
            rank = sorted_rank(L, event.seg)
            if rank-1 >= 1
                code,inters = find_intersect(L[rank],L[rank-1])
                if inters != nothing
                    push!(Q,Event(L[rank],L[rank-1],inters))
                end
            end
            if rank+1 <= length(L)
                code,inters = find_intersect(L[rank],L[rank+1])
                if inters != nothing
                    push!(Q,Event(L[rank],L[rank+1],inters))
                end
            end
        elseif event.typ == 2
            rank = sorted_rank(L,event.seg)
            if rank-1 >= 1 && rank+1 <= length(L)
                code,inters = find_intersect(L[rank-1],L[rank+1])
                if inters != nothing
                    push!(Q,Event(L[rank-1],L[rank+1],inters))
                end
            end
            delete!(L, L[rank])
        elseif event.typ == 3
            println(event.inters)
            aux = 0
            s1 = event.seg
            s2 = event.seg2
            r1 = sorted_rank(L,s1)
            delete!(L,L[r1])
            r2 = sorted_rank(L,s2)
            delete!(L,L[r2])
            s1.minx, s2.minx = s2.minx, s1.minx
            push!(L,s1)
            push!(L,s2)
        end
    end
end
