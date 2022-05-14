using Plots


mutable struct convexHull

    points::Array{BigInt,1}
    
end

mutable struct Point
    x
    y
    
end

function readPoints(path) 

    file = open(path)
    lines = readlines(file);
    close(file)
    
    
    numberOfLines = length(lines)
    points = [Point(0,0) for i in 1:numberOfLines]
    
    for i in 1:numberOfLines
        
        line = split(lines[ i ], " ")
        
        points[ i ].x = parse(BigInt,line[ 1 ])
        points[ i ].y = parse(BigInt,line[ 2 ])
        
        
    end    
    
    return points
    
end

function pointsToVectors(Points)

    x = []
    y = []
    
    for i in Points
        push!(x,i.x)
        push!(y,i.y)
    end
    
    return x, y
    
end

function showPoints(points)
    
    x, y = pointsToVectors(points)

    plt = scatter(x,y, color="red",primary=false)
        
    return plt
    
end

function nextToTop(Points)

    p = Points[end]
    pop!(Points)
    res = Points[end]
    push!(Points,p)
    return res
    
end
 
function distSq(p1::Point, p2::Point)

    return (p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y)
end
 
# To find orientation of ordered triplet (p, q, r).
# The function returns following values
# 0 --> p, q and r are collinear
# 1 --> Clockwise
# 2 --> Counterclockwise
function orientation(p::Point, q::Point, r::Point)

    val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
    
    if val == 0 
        return 0  # collinear
    end
    if val > 0
        return 1
    end
    
    return 2
              
end
 

function compare( vp1::Point, vp2::Point, vp0::Point)

   p1 = vp1
   p2 = vp2
   p0 = vp0
   
   o = orientation(p0, p1, p2)
    
   if o == 0
        if distSq(p0, p2) >= distSq(p0, p1)
            return false
        else
            return true
        end
   end
   
   if o == 2
       return false
   else
       return true
   end
                    
end
 
function partition(points, low, high, p0)
    
    pivot = points[ high ]
    i = low - 1
 
    for j in low:high
    
        if compare( pivot, points[ j ], p0)
            i += 1 
            points[ i ], points[ j ] = points[ j ], points[ i ]
        end
    end
        
    points[i + 1], points[high] = points[ high ], points[i + 1]
        
    return points, i + 1
        
end
 
function quickSort(points, low, high, p0)

    if low < high
       
       
        points ,pi = partition(points, low, high, p0)
 
        quickSort(points, low, pi - 1, p0)
        quickSort(points, pi + 1, high, p0)
            
    end
        
end

function convexHullGrahamScan(points)
                      
   n = length(points)
   ymin = points[1].y
   min = 1
    
   for i in 2:n
        
     y = points[i].y
 
     if (y < ymin) || ((ymin == y) && (points[i].x < points[min].x))
        ymin = points[i].y
        min = i
     end
   end
 
   points[ 1 ], points[ min ] = points[min], points[1]
 
   p0 = points[1]
    
   quickSort(points, 2, n , p0)
 
   m = 2
   i = 2
   while i <= n
        
       while (i < n) && (orientation(p0, points[i], points[i+1]) == 0)
          i+=1
       end
       
       points[ m ] = points[ i ]
       m+=1  
       i+=1
   end

   m -= 1
    
   if m < 3 
      return []
   end
 
   S = [p0]
   push!(S, points[2])
   push!(S, points[3])
 
   for i in 4:m
        while (length(S) > 1) && (orientation(nextToTop(S), S[end], points[i]) != 2)
         pop!(S)
        end
        push!(S, points[ i ])
    end
 
   # Now stack has the output points, print contents of stack
   Sol = []
   while length(S) > 0
   
       p = S[end]
       push!(Sol,p)
       pop!(S)
   end    
    
   return Sol
    
end

function showConvexHull(ConvexHull, Points)


    CHx, CHy = pointsToVectors(ConvexHull)
    x, y     = pointsToVectors(Points)
    
    auxx = []
    auxy = []
    push!(auxx, CHx[ 1 ])
    push!(auxy, CHy[ 1 ])
    push!(auxx, CHx[ end ])
    push!(auxy, CHy[ end ])
    
    plt = plot(CHx,CHy, color="blue",primary=false)
    plt = scatter!(plt,x,y, color="red",primary=false)
    plt = plot!(plt, auxx, auxy,color="blue",primary=false)
    
    return plt

end


function convexHullGiftWrapping( points )

 
    n = length(points)
    
    if n < 3 
        return []
    end
 
    hull=[];
 
    l = 1;
    for  i in 2:n
        if points[i].x < points[l].x
            l = i;
        end
    end
 
    p = l
    q = (p + 1) % n
          
    push!(hull,points[p])
        
    for i in 1:n
        if (orientation(points[p], points[i], points[q]) == 2)
               q = i
        end
    end
 
        
    p = q;
 
    while (p != l)
            
        push!(hull,points[p])
        
        q = (p + 1) % n
        for i in 1:n
            if (orientation(points[p], points[i], points[q]) == 2)
                   q = i
            end
        end
 
        p = q
            
    end
 
    
    return hull;
        
end





