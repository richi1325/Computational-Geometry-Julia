mutable struct Vertex
    value
    next::Union{Vertex,Nothing}
    prev::Union{Vertex,Nothing}
    function Vertex(value::Vector)
        this = new()
        this.value = value
        this.next = nothing
        this.prev = nothing
        return this
    end
end

mutable struct Polygon
    head::Vertex
    dim::Integer
    n::Integer
    function Polygon(values...)
        n = length(values)
        dim = length(values[1])
        for v in values
            if length(v) != dim
                throw(error("All vectors must be the same length"))
            end
        end
        this = new()
        this.dim = dim
        this.n = n
        vertex = [Vertex(v) for v in values]
        this.head = vertex[1]
        this.head.next = vertex[2]
        this.head.prev = vertex[n]
        vertex[n].next = vertex[1]
        vertex[n].prev = vertex[n-1]
        i = 2
        while i<=n-1
            vertex[i].next = vertex[i+1]
            vertex[i].prev = vertex[i-1]
            i += 1
        end
        return this
    end
end

mutable struct Segment
    a::Vector
    b::Vector
    minx
    function Segment(a, b)
        this = new()
        this.a = a
        this.b = b
        if this.a[2] > this.b[2]
            this.minx = this.a[1]
        else
            this.minx = this.b[1]
        end
        return this
    end
end

mutable struct Event
    seg::Segment
    seg2
    p0::Vector
    p1::Vector
    inters
    height
    typ
    function Event(seg::Segment,typ::Int)
        this = new()
        this.seg = seg
        if seg.a[2] > seg.b[2]
            this.p0 = seg.a
            this.p1 = seg.b
        else
            this.p0 = seg.b
            this.p1 = seg.a
        end
        this.typ = typ
        if typ == 1
            this.height = this.p0[2]
        elseif typ == 2
            this.height = this.p1[2]
        end
        #println(this.p0,">",this.p1,"   h:", this.height,"   type:", this.typ)
        return this
    end
    
    function Event(seg::Segment,seg2::Segment,inters::Vector)
        this = new()
        this.seg = seg
        this.seg2 = seg2
        this.inters = inters
        this.typ = 3
        this.height = inters[2]
        return this
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
    return det(M)/2
end

function getvolume(v0::Vector, v1::Vector, v2::Vector, v3::Vector)
    M = [
    v0[1] v0[2] v0[3] 1
    v1[1] v1[2] v1[3] 1
    v2[1] v2[2] v2[3] 1
    v3[1] v3[2] v3[3] 1
    ]
    return det(M)/6
end

mutable struct Polyhedron
    faces
    vertices
    function Polyhedron(vertices,faces...)
        this = new()
        n = length(faces)
        dim = length(vertices[1])
        if n < 4
            throw(error("Polyhedron must have at least 4 faces"))
        end
        if dim != 3
            throw(error("Polyhedron must have elements on 3D"))
        end
        this.faces = []
        for f in faces
            push!(this.faces, Polygon(vertices[f]...))
        end
        this.vertices = collect(vertices)
        return this
    end
end

function Base.show(io::IO, ::MIME"text/html", vertex::Vertex)
  print(io, k.value)
end

function Base.show(io::IO, ::MIME"text/html", pol::Polygon)
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

function Base.show(io::IO, ::MIME"text/html", seg::Segment)
    print(io, seg.a)
    print(io,"->")
    print(io, seg.b)
end

function Base.show(io::IO, ::MIME"text/html", hedron::Polyhedron)
    for vertex in hedron.vertices
        print(io, vertex)
        print(io, "--")
    end
end

function Base.show(io::IO, ::MIME"text/html", eve::Event)
    if eve.typ == 1
        print("Insert: ",eve.seg)
    elseif eve.typ == 2
        print("Delete: ",eve.seg)
    elseif eve.typ == 3
        print("Intersection: ",eve.inters)
    end
end

function map_jerarquy(t1)
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