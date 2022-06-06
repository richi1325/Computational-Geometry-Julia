include("_types.jl")
import LinearAlgebra
const la = LinearAlgebra

function dist(v1::Vector,v2::Vector)
    return sum((v1-v2) .^ 2) ^ 0.5
end

function test(func, test_name,params,expected)
    obt = func(params...)
    if obt == expected
        println("$(test_name) passed")
    else
        println("$(test_name) failed exp:$(expected) obt:$(obt)")
    end
end

function flatpolygon(pol::Polygon)
    vals = [copy(pol.head.value)]
    cur = pol.head.next
    while cur != pol.head
        push!(vals, copy(cur.value))
        cur = cur.next
    end
    return vals
end

function getarea(x0::Vector, x1::Vector, x2::Vector)
    M = [
        x0[1] x0[2] 1
        x1[1] x1[2] 1
        x2[1] x2[2] 1
    ]
    return la.det(M)/2
end

function getvolume(v0::Vector, v1::Vector, v2::Vector, v3::Vector)
    M = [
    v0[1] v0[2] v0[3] 1
    v1[1] v1[2] v1[3] 1
    v2[1] v2[2] v2[3] 1
    v3[1] v3[2] v3[3] 1
    ]
    return la.det(M)/6
end

function Base.show(io::IO, vertex::Vertex)
  print(io, vertex.value)
end

function Base.show(io::IO, pol::Polygon)
    cur = pol.head
    while true
        print(io, cur.value)
        print(io,"->")
        cur = cur.next
        if cur == pol.head
            break
        end
    end
end

function Base.show(io::IO, seg::Segment)
    print(io, seg.a)
    print(io,"->")
    print(io, seg.b)
end

function Base.show(io::IO, hedron::Polyhedron)
    for vertex in hedron.vertices
        print(io, vertex)
        print(io, "--")
    end
end

function Base.show(io::IO, eve::Event)
    if eve.typ == 1
        print("Insert: ",eve.seg)
    elseif eve.typ == 2
        print("Delete: ",eve.seg)
    elseif eve.typ == 3
        print("Intersection: ",eve.inters)
    end
end

function map_jerarquy(t1::Int)
    if t1 == 1
        return 1
    end
    if t1 == 2
        return 3
    end
    return 2
end

function break_tie(e1,e2)
    if (e1.typ == e2.typ == 3)
        return e1.inters[1] < e2.inters[1]
    end
    if (e1.typ == e2.typ == 2)
        return e1.p1[1] < e2.p1[1]
    end
    return e1.p0[1] > e2.p0[1]
end

function Base.:<(e1::Event,e2::Event)
    if e1.height == e2.height
        j1 = map_jerarquy(e1.typ)
        j2 = map_jerarquy(e2.typ)
        if j1 == j2
            return break_tie(e2,e1)
        end
        if j1 < j2
            return true
        end
        return false
    end
    return e1.height > e2.height
end

function Base.:>(e1::Event,e2::Event)
    if e1.height == e2.height
        j1 = map_jerarquy(e1.typ)
        j2 = map_jerarquy(e2.typ)
        if j1 == j2
            return break_tie(e1,e2)
        end
        if j1 > j2
            return true
        end
        return false
    end
    return e1.height < e2.height
end

function Base.:(==)(e1::Event,e2::Event)
    if e1.typ != e2.typ
        return false
    end
    if e1.typ == 1 || e1.typ == 2
        return e1.p0 == e2.p0 && e1.p1 == e2.p1
    end
    return e1.inters == e2.inters
end

function Base.:<(s1::Segment,s2::Segment)
    return s1.minx < s2.minx
end

function Base.:>(s1::Segment,s2::Segment)
    return s1.minx > s2.minx
end

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

function midway(a, b, n)
    if a < b
        return Int(ceil((a+b)/2))
    else
        return Int(ceil(((a+b+n)/2)%n)+1)
    end
end

function prev_next(c,n)
    prev = (n+c-2)%n + 1
    next = (n+c)%n + 1
    return Int(prev),Int(next)
end

function flatpolygon_vertex(pol::Polygon,npol::Int)
    vals = [(pol.head,npol)]
    cur = pol.head.next
    while cur != pol.head
        push!(vals,(cur,npol))
        cur = cur.next
    end
    return vals
end

function get_xy(pol::Polygon)
    fp = flatpolygon(pol)
    x = [v[1] for v in fp]
    y = [v[2] for v in fp]
    push!(x,x[1])
    push!(y,y[1])
    return x,y
end

function get_xy(seg::Segment)
    x = [seg.a[1],seg.b[1]]
    y = [seg.a[2],seg.b[2]]
    return x,y
end

function plot(p::Polygon; color=:red, width=5)
    marker=(:circle,5,color)
    x,y = get_xy(p)
    return Plots.plot(x,y,linecolor=color,marker=marker,linewidth=width, legend=false)
end

function plot!(p::Polygon, pin=nothing; color=:red, width=5)
    marker=(:circle,5,color)
    x,y = get_xy(p)
    return Plots.plot!(x,y,linecolor=color,marker=marker,linewidth=width,legend=false)
end

function plot(s::Segment; color=:red, width=5)
    marker=(:circle,5,color)
    x,y = get_xy(s)
    return Plots.plot(x,y,linecolor=color,marker=marker,linewidth=width, legend=false)
end

function plot!(s::Segment; color=:red, width=5)
    marker=(:circle,5,color)
    x,y = get_xy(s)
    return Plots.plot!(x,y,linecolor=color,marker=marker,linewidth=width, legend=false)
end

function plot(v::Vertex; color=:red, width=5)
    marker=(:circle,5,color)
    x,y = [v.value[1]],[v.value[2]]
    return Plots.scatter(x,y,marker=marker, legend=false)
end

function plot!(v::Vertex; color=:red, width=5)
    marker=(:circle,5,color)
    x,y = [v.value[1]],[v.value[2]]
    return Plots.scatter!(x,y,marker=marker, legend=false)
end

function plot(vg::Dict; color=:red, width=5)
    marker=(:circle,5,color)
    first = true
    plotin = nothing
    for (k,vals) in vg
        for (v,d) in vals
            if first
                first = false
                plot(Vertex(v),color=:white)
            end
            x = [k[1],v[1]]
            y = [k[2],v[2]]
            Plots.plot!(x,y;marker=marker,linecolor=color, linewidth=width, legend=false)
        end
    end
    return plotin
end

function plot!(vg::Dict; color=:red, width=5)
    marker=(:circle,5,color)
    # plot visibility graph
    plotin = nothing
    for (k,vals) in vg
        for (v,d) in vals
            x = [k[1],v[1]]
            y = [k[2],v[2]]
            plotin = Plots.plot!(x,y;marker=marker,linecolor=color, linewidth=width, legend=false)
        end
    end
    return plotin
end