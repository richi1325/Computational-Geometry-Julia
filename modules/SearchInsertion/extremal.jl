include("_types.jl")
include("_util.jl")
import LinearAlgebra
const la = LinearAlgebra

function find_extremal(pol::Polygon,u::Vector = [0,1])
    poly = flatpolygon(pol)
    n = length(poly)
    a, b  = Int(1), Int(n)
    while true
        a_prev,_ = prev_next(a,n)
        b_prev,_ = prev_next(b,n)
        c = midway(a,b,n)
        c_prev,c_next = prev_next(c,n)
        A = poly[a]-poly[a_prev] 
        B = poly[b]-poly[b_prev]
        C = poly[c]-poly[c_prev]
        la.dot(u,poly[c]-poly[c_prev]) > 0
        if (la.dot(u,poly[c]-poly[c_next]) > 0) && (la.dot(u,poly[c]-poly[c_prev]) > 0)
            return poly[c]
        end
        V = la.dot(A,u)
        W = la.dot(C,u)
        if (V > 0) && (W < 0)
            a,b = a,c
        elseif (V < 0) && (W > 0)
            a,b = c,b
        elseif (V > 0) && (W > 0)
            if la.dot(u,poly[a]-poly[c]) > 0
                a,b = a,c
            else
                a,b = c,b
            end
        elseif (V < 0) && (W < 0)
            if la.dot(u,poly[c]-poly[a]) > 0
                a,b = a,c
            else
                a,b = c,b
            end
        end
    end
end