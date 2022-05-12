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

function getvolume(v0::PointR3, v1::PointR3, v2::PointR3, v3::PointR3)
    M = [
    v0[1] v0[2] v0[3] 1
    v1[1] v1[2] v1[3] 1
    v2[1] v2[2] v2[3] 1
    v3[1] v3[2] v3[3] 1
    ]
    return det(M)/6
end
    
