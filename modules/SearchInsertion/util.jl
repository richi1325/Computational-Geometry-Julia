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
    function Segment(a, b)
        this = new()
        this.a = a
        this.b = b
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