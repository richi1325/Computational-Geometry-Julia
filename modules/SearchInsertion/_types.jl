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
        if seg.a[1] < seg2.a[1]
            this.seg = seg
            this.seg2 = seg2
        else
            this.seg = seg2
            this.seg2 = seg
        end
        this.inters = inters
        this.typ = 3
        this.height = inters[2]
        return this
    end
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