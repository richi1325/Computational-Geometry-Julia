include("segment.jl")
include("util.jl")
using DataStructures

function inout(inters, inflag, aHB, bHA)
    if aHB > 0
        return "Pin"
    end
    if bHA > 0
        return "Qin"
    end
    return inflag
end

function advance(a, aa, n, inside, v)
    if inside
        return (a+1)%n, aa+1, v
    end
    return (a+1)%n, aa+1, nothing
end

function convpol_intersect(P::Polygon, Q::Polygon)
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

function segments_intersects(segs...)
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
