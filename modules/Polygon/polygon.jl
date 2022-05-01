using Plots

mutable struct Vertex
    x
    y
    next
    prev    
    ear
    
    function Vertex()
        this = new()
        this.x = nothing
        this.y = nothing
        this.next = nothing
        this.prev = nothing
        this.ear = nothing
        return this
    end
end

mutable struct Polygon
    v_num
    pol
    
    function Polygon()
        this = new()
        this.v_num = 0
        this.pol = Vertex()
        return this
    end
end

function Base.getproperty(this::Polygon, s::Symbol)
    #Métodos privados    
    _Area = function(a, b, c)
        return 0.5*((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y))
    end
    
    _AreaSign = function(a, b, c)
        area = _Area(a, b, c)
        if area > 0.0000001
            return 1
        elseif area < -0.0000001
            return -1
        else
            return 0
        end
    end
    
    _Left = function(a, b, c) 
        return _AreaSign(a, b, c) > 0
    end

    _LeftOn = function(a, b, c) 
        return _AreaSign(a, b, c) >= 0
    end
    
    _Collinear = function(a, b, c) 
        return _AreaSign(a, b, c) == 0
    end
    
    _InCone = function(a, b)
        a1 = a.next;
        a0 = a.prev;
        if _LeftOn(a, b, a1)
            return _Left(a, b, a0) && _Left(b, a, a1)
        else
            return !(_LeftOn(a, b, a1) && _LeftOn(b, a, a0)) 
        end
    end
    
    _Xor = function (x, y)
        return x ⊻ y
    end 
    
    _IntersectProp = function(a,b,c,d)
       if (
          _Collinear(a,b,c) ||
          _Collinear(a,b,d) ||
          _Collinear(c,d,a) ||
          _Collinear(c,d,b)
        )
            return false
        end
        return _Xor(_Left(a, b, c), _Left(a, b, d)) && 
                _Xor(_Left(c, d, a), _Left(c, d, b))
    end

    _Between = function(a, b, c)
        if !_Collinear(a, b, c)
            return false
        elseif a.x != b.x 
            return ((a.x <= c.x) && (c.x <= b.x)) ||
                    ((a.x >= c.x) && (c.x >= b.x))
        else
            return ((a.y <= c.y) && (c.y <= b.y)) ||
                    ((a.y >= c.y) && (c.y >= b.y))
        end
    end
    
    _Intersect = function(a, b, c, d)
        if _IntersectProp(a, b, c, d)
            return true
        elseif (_Between(a, b, c) ||
                _Between(a, b, d) ||
                _Between(c, d, a) ||
                _Between(c, d, b)
        )
            return true
       else
            return false
        end
    end

    _Diagonalie = function(a, b)
        c = this.pol
        while true
            c1 = c.next
            if ((c != a) && (c1 != a)
                && (c != b) && (c1 != b)
                && _Intersect(a, b, c, c1)
            )
                 return false
            end
            c = c.next;
            if c==this.pol
                break
            end
        end
        return true
    end

    _Diagonal = function (a, b)
        return _InCone(a, b) && _InCone(b, a) && _Diagonalie(a, b)
    end

    _EarInit = function()
        v1 = this.pol
        while true 
            v2 = v1.next
            v0 = v1.prev
            v1.ear = _Diagonal(v0, v2)
            v1 = v1.next
            if v1 == this.pol
                break
            end
        end
    end        

    _PrintDiagonal = function (a, b)
       print("$(a.x)\t$(a.y)\tmoveto\n")
       print("$(b.x)\t$(b.y)\tlineto\n")
    end

    if s == :Insertar
        function(route)
            file = open(route)
                points = readlines(file)
            close(file)
            aux = this.pol
            aux2 = this.pol
            this.v_num = length(points)
            for i=1:this.v_num
                coor = split(points[i]," ")
                aux.x = parse(BigInt,coor[1])
                aux.y = parse(BigInt,coor[2])
                if i < this.v_num
                    aux.next = Vertex()
                    aux = aux.next
                    aux.prev = aux2
                    aux2 = aux
                else
                    aux.next = this.pol
                    this.pol.prev = aux2
                end
            end
        end
    elseif s == :Plot
        function()
            aux = this.pol
            x = []
            y = []
            while true
                push!(x,aux.x)
                push!(y,aux.y)
                aux = aux.next                
                if aux == this.pol
                    break
                end
            end
            push!(x,aux.x)
            push!(y,aux.y)
            plotin = plot(x, y,color="black",primary = false)
            plotin = scatter!(x,y,color="red",primary = false)
            return plotin
        end
    elseif s == :Area
        function()
            sum = 0
            p = this.pol
            a = this.pol.next
            while true
                sum += _Area(p, a, a.next)
                a = a.next
                if a.next == p
                    break
                end
            end
            return sum
        end
    elseif s == :Triangular
        function()
            _EarInit()
            temp = deepcopy(this.pol)
            diagonales = []
            while this.v_num > 3 
                v2 = this.pol
                while true
                    if v2.ear
                        v3 = v2.next
                        v4 = v3.next
                        v1 = v2.prev
                        v0 = v1.prev
                        push!(diagonales,[[v1.x,v3.x],[v1.y,v3.y]])
                        v1.ear = _Diagonal(v0, v3)
                        v3.ear = _Diagonal(v1, v4)
                        v1.next = v3
                        v3.prev = v1
                        this.pol = v3
                        this.v_num -= 1
                        break
                    end
                    v2 = v2.next
                    if v2 == this.pol
                        break
                    end
                end
            end
            this.pol = temp
            plotin = this.Plot()
            for i=1:length(diagonales)
                plotin = plot!(diagonales[i][1], diagonales[i][2],color="blue",primary = false)
            end
            display(plotin)
        end
    else
        getfield(this, s)
    end
end