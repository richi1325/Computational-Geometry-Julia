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
    #-----------------------------------------------------------------------------
    # Devuelve el doble del área con signo del triángulo determinada por a, b y c.
    # El área es positiva si a, b y c están orientadas hacia la izquierda
    # El área es negativa si está orientado hacia la derecha, y
    # cero si los puntos son colineales.
    #----------------------------------------------------------------------------
    _Area = function(a, b, c)
        return (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)
    end
    
    #-----------------------------------------------------------------------------
    # Devuelve verdadero sii c está estrictamente a la izquierda del segmento ab.
    #-----------------------------------------------------------------------------
    _Left = function(a, b, c) 
        return _Area(a, b, c) > 0
    end

    #-----------------------------------------------------------------------------
    # Devuelve verdadero sii c está a la izquierda o es colineal al segmento ab.
    #-----------------------------------------------------------------------------
    _LeftOn = function(a, b, c) 
        return _Area(a, b, c) >= 0
    end
    
    #-----------------------------------------------------------------------------
    # Devuelve verdadero sii c es colineal al segmento ab.
    #-----------------------------------------------------------------------------
    _Collinear = function(a, b, c) 
        return _Area(a, b, c) == 0
    end

    #-----------------------------------------------------------------------------
    # Devuelve verdadero si la diagonal ab es estrictamente interna al
    # polígono en la vecindad del punto final a.
    #-----------------------------------------------------------------------------
    _InCone = function(a, b)
        a1 = a.next
        a0 = a.prev
        if _LeftOn(a, b, a1)
            return _Left(a, b, a0) && _Left(b, a, a1)
        else
            return !(_LeftOn(a, b, a1) && _LeftOn(b, a, a0)) 
        end
    end
    
    #-----------------------------------------------------------------------------
    # O exclusivo: Es verdadero si exactamente un argumento es verdadero.
    #-----------------------------------------------------------------------------
    _Xor = function (x, y)
        return x ⊻ y
    end 

    #-----------------------------------------------------------------------------
    # Devuelve verdadero si ab intersecta correctamente a cd (ambos segmentos 
    # comparten un punto interior). La propiedad de la intersección se asegura mediante
    # el uso estricto de la izquierda.
    #-----------------------------------------------------------------------------
    _IntersectProp = function(a,b,c,d)
       if (
          _Collinear(a,b,c) ||
          _Collinear(a,b,d) ||
          _Collinear(c,d,a) ||
          _Collinear(c,d,b)
        )
            return false
        else
            return _Xor(_Left(a, b, c), _Left(a, b, d)) && 
                   _Xor(_Left(c, d, a), _Left(c, d, b))
        end
    end

    #-----------------------------------------------------------------------------
    # Devuelve verdadero si el punto c se encuentra en el segmento cerrado ab.
    # Primero se comprueba que c es colineal con a y b.
    #-----------------------------------------------------------------------------
    _Between = function(a, b, c)
        if !(_Collinear(a, b, c))
            return false
        elseif a.x != b.x 
            return ((a.x <= c.x) && (c.x <= b.x)) ||
                    ((a.x >= c.x) && (c.x >= b.x))
        else
            return ((a.y <= c.y) && (c.y <= b.y)) ||
                    ((a.y >= c.y) && (c.y >= b.y))
        end
    end

    #-----------------------------------------------------------------------------
    # Devuelve verdadero si los segmentos ab y cd se cruzan, correcta o incorrectamente.
    #-----------------------------------------------------------------------------
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

    #-----------------------------------------------------------------------------
    # Devuelve verdadero si ab es una diagonal propia interna o externa de P
    # Ignorando las aristas incidentes a "a" y "b".
    #-----------------------------------------------------------------------------
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
            if c == this.pol
                break
            end
        end
        return true
    end

    #-----------------------------------------------------------------------------
    # Devuelve verdadero si ab es una diagonal propia interna.
    #-----------------------------------------------------------------------------
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
            _EarInit()
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
            return 0.5*sum
        end
    elseif s == :Triangular
        function(plot_pol = true)
            temp = deepcopy(this.pol)
            diagonales_plot = []
            diagonales = []
            n = this.v_num
            while n > 3
                earfound = false
                v2 = this.pol
                while true
                    if v2.ear
                        earfound = true
                        v3 = v2.next
                        v4 = v3.next
                        v1 = v2.prev
                        v0 = v1.prev
                        
                        push!(diagonales_plot,[[v1.x,v3.x],[v1.y,v3.y]])
                        push!(diagonales,[[v1.x,v1.y],[v3.x,v3.y]])
                        
                        v1.ear = _Diagonal(v0, v3)
                        v3.ear = _Diagonal(v1, v4)
                        
                        v1.next = v3
                        v3.prev = v1
                        this.pol = v3
                        n -= 1
                        break
                    end
                    v2 = v2.next
                    if v2 == this.pol
                        break
                    end
                end
                if !earfound
                    _EarInit()
                end
            end
            this.pol = temp
            if plot_pol
                plotin = this.Plot()
                for i=1:length(diagonales_plot)
                    plotin = plot!(diagonales_plot[i][1], diagonales_plot[i][2],color="blue",primary = false)
                end
                display(plotin)
            end
            return diagonales
        end
    else
        getfield(this, s)
    end
end