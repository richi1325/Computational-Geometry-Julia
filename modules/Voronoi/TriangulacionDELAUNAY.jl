using Plots
#Variables globales 

 ONHULL=true
 REMOVED=true
 VISIBLE=true
 PROCESSED=true
 SAFE=1000000 
 debug = false
 check = false
 vertices = nothing
 edges  =nothing
 faces = nothing
 X=0
 Y=1
 Z=2

# Declarando estructuras 
mutable struct tVertex
    x
    y
    z
    vnum::Int64
    duplicate::Bool
    onhull::Bool
    mark::Bool
    next::Array{1}
    prev::Array{1}
    
end
function tVertex(tVertex)
       #this=new()
       tVertex.x =nothing
       tVertex.y = nothing
       tVertex.z = nothing
       tVertex.duplicate = false
       tVertex.onhull =false
       tVertex.mark =false
       
       tVertex.next = nothing
       tVertex.prev = nothing
       tVertex.vnum = nothing
       return tVertex
    end

mutable struct tEdge
     
     adjface1::Array{1}
     adjface2::Array{1}
     endpts1::Array{1}
     endpts2::Array{1}
     newface::Array{1}            
     delete::Bool  
     next::Array{1}
     prev::Array{1}
     
end
function tEdge(tEdge)

          #this=new()
          tEdge.adjface1=nothing
          tEdge.adjface2=nothing
          tEdge.newface=nothing
          tEdge.endpts1=nothing
          tEdge.endpts2 = nothing
          tEdge.delete =false
          tEdge.next=nothing
          tEdge.prev=nothing
 
      return tEdge
end

mutable struct tFace
    edge1::Array{1}
    edge2::Array{1}
    edge3::Array{1}
    vertex::Array{3}
    visible::Bool       
    lower::Bool          
    next::Array{1}
    prev::Array{1}
    
    

end
function tFace(tFace)
     

        #this=new()
        tFace.edge1 = nothing
        tFace.edge2 = nothing
        tFace.edge3 = nothing
        tFace.vertex[0]=nothing
        tFace.vertex[1]=nothing
        tFace.vertex[2]=nothing
        tFace.visible =false
        tFace.lower=false
        tFace.next=nothing
        tFace.prev=nothing
   
        return tFace
end
mutable struct Planoclass
    
    s_num::Int64
    sfaces::Array{1}
    spots::Array{1}
    sedges::Array{1}
         function Planoclass()
               this=new()
               this.s_num = 0
               this.sfaces=tFace(this.sfaces::tFace)
               this.spots=tVertex(this.spots::tVertex)
               this.sedges=tEdge(this.sedges::tEdge)
               return this

         end
end


function Base.getproperty(this::Planoclass, sym::Symbol)
        #Métodos privados
     _LowerFaces=function()

         f11= faces 
  
         Flower= 0    

         while true 
              if ( _Normz( f11 )< 0 ) 
                       Flower=Flower+1
                       f11.lower=true 
               
       
            else f11.lower= false
               end
               f11 = f11.next
               if f11==faces
                    break
               end
         end
         
        
        
     end
     _SubVec=function( a,b,c)

         c.x = a.x - b.x
         c.y = a.y - b.y
         c.z = a.z - b.z

     end
   _DoubleTriangle=function()

      v00,v1,v2,v3,t 
      f0,f1 
      e0,e1, e2
      vol
      v00 = vertices
      aux=v00.next
      while ( _Collinear( v00, v00.next, aux.next ) )
            if ( ( v00 = v00.next ) == vertices )
               exit(0)
            end
      end
      v1 = v00.next
      v2 = v1.next

      # Mark the vertices as processed
      v00.mark = PROCESSED
      v1.mark = PROCESSED
      v2.mark = PROCESSED
   
      #* Create the two "twin" faces. */
      f0 = _MakeFace( v00, v1, v2, f1 )
      f1 = _MakeFace( v2, v1, v00, f0 )

      #Link adjacent face fields. */
      f0.edge1.adjface2 = f1
      f0.edge2.adjface2 = f1
      f0.edge3.adjface2= f1
      f1.edge1.adjface2= f0
      f1.edge2.adjface2= f0
      f1.edge3.adjface2= f0

   #Find a fourth, non-coplanar point to form tetrahedron. */
      v3 = v2.next
      vol = _VolumeSign( f0, v3 )
       while ( !vol )   
           if ( ( v3 = v3.next ) == v00 ) 
              exit(0)
           end
       vol = _VolumeSign( f0, v3 )
       end

       #Insure that v3 will be the first added. */
      vertices = v3
         
       

    end
     _DELETE=function(head, p )
          if ( head )  
              if ( head == head.next ) 
                        head =nothing
              elseif ( p == head ) 
                  head = head.next
                   
              end
              p.next.prev = p.prev
              p.prev.next = p.next
              _FREE( p )
          end
        return p
     end
    _SWAP=function(t,x,y)
            
            t = x
            x = y
            y = t
           return t,x,y
    end
    _FREE=function(p)
            if (p) 
                 free(p)
                 p = nothing
            end
            return p
    end
 
    _ConstructHull=function()

     vol
     changed   #T if addition changes hull  not used. */

     v = vertices
      while true
        vnext = v.next
        if ( !v.mark ) 
           v.mark = PROCESSED
           changed =_AddOne( v )
           _CleanUp()

           if ( check ) 
	         println("ConstructHull: After Add of %d & Cleanup:\n",v.vnum)
	         _Checks()
           end
        end
        v = vnext
        if v==vertices
             break
        end
       end
    
    end
    
     _VolumeSign=function( f33, p )
     
               vol
               voli 
               ax, ay, az, bx, by, bz, cx, cy, cz, dx, dy, dz
              bxdx, bydy, bzdz, cxdx, cydy, czdz

             ax = f33.vertex[0].x
             ay = f33.vertex[0].y
             az = f33.vertex[0].z
             bx =f33.vertex[1].x
             by = f33.vertex[1].y
             bz = f33.vertex[1].z
             cx = f33.vertex[2].x
             cy = f33.vertex[2].y
             cz = f33.vertex[2].z
             dx =p.x
             dy =p.y
             dz=p.z
   
             bxdx=bx-dx
             bydy=by-dy
             bzdz=bz-dz
             cxdx=cx-dx
             cydy=cy-dy
             czdz=cz-dz
             vol =   (az-dz) * (bxdx*cydy - bydy*cxdx)+ (ay-dy) * (bzdz*cxdx - bxdx*czdz)+ (ax-dx) * (bydy*czdz - bzdz*cydy)

             

  #The volume should be an integer. */
             if( vol > 0.5 )  
                      return  1
             elseif( vol < -0.5 ) 
                      return -1
                  else  return  0
                  
                                                
             end
    end
    _Volumei=function(fu, p )

         vol
         ax, ay, az, bx, by, bz, cx, cy, cz, dx, dy, dz
         bxdx, bydy, bzdz, cxdx, cydy, czdz
         vold
          i

             ax = fu.vertex[0].x
             ay = fu.vertex[0].y
             az = fu.vertex[0].z
             bx =fu.vertex[1].x
             by = fu.vertex[1].y
             bz = fu.vertex[1].z
             cx = fu.vertex[2].x
             cy = fu.vertex[2].y
             cz = fu.vertex[2].z
             dx =p.x
             dy =p.y
             dz=p.z
   
            bxdx=bx-dx
            bydy=by-dy
            bzdz=bz-dz
            cxdx=cx-dx
            cydy=cy-dy
            czdz=cz-dz
             vol =(az-dz)*(bxdx*cydy-bydy*cxdx) + (ay-dy)*(bzdz*cxdx-bxdx*czdz)+ (ax-dx)*(bydy*czdz-bzdz*cydy)

            return vol
     end
     _Volumed=function(f4,p)

            
             
             ax = f4.vertex[0].x
             ay = f4.vertex[0].y
             az = f4.vertex[0].z
             bx =f4.vertex[1].x
             by = f4.vertex[1].y
             bz = f4.vertex[1].z
             cx = f4.vertex[2].x
             cy = f4.vertex[2].y
             cz = f4.vertex[2].z
            dx = p.x
            dy = p.y
            dz = p.z
   
            bxdx=bx-dx
            bydy=by-dy
            bzdz=bz-dz
            cxdx=cx-dx
            cydy=cy-dy
            czdz=cz-dz
            vol = (az-dz)*(bxdx*cydy-bydy*cxdx)+(ay-dy)*(bzdz*cxdx-bxdx*czdz)+(ax-dx)*(bydy*czdz-bzdz*cydy)

            return vol
     end
     _AddOne=function(p) 
        vis = false 
        f22 = faces
        while true
              vol=_VolumeSign(f22, p)
            
              if(vol<0 ) 
	               f22.visible= true
	               vis=true                   
              end
          
              f22 =f22.next
              if(f22==faces)
                    break
              end
         end
      

         if(!vis)
                 p.onhull =false  
                 return false
         end
         e = edges
         while true
             temp = e.next
             if ( e.adjface1.visible && e.adjface2.visible )
	                   e.delete =true
             elseif ( e.adjface1.visible || e.adjface2.visible ) 
	              
	                   e.newface= _MakeConeFace(e,p)
                       e=temp
                  
             end
             if e==edges
                    break
             end
         end
         return true
     end
    _MakeConeFace=function(e11, p)
                                                
        new_edge3
        new_face
        i, j 

  #Make two new edges (if don't already exist). */
     
     # /* If the edge exists, copy it into new_edge. */
        if ( !( new_edge1 = e11.endpts1.duplicate) ) 
                                                    
        #Otherwise (duplicate is NULL), MakeNullEdge. */
	         new_edge1 
	         new_edge1.endpts1 = e11.endpts1
	         new_edge1.endpts2 = p
	         e11.endpts1.duplicate = new_edge1
         end
         if ( !( new_edge2 = e11.endpts2.duplicate) ) 
                                                    
        #Otherwise (duplicate is NULL), MakeNullEdge. */
	         new_edge2  
	         new_edge2.endpts1 = e11.endpts2
	         new_edge2.endpts2 = p
	         e11.endpts2.duplicate = new_edge2
         end
   

     
      new_face.edge1 = e11
      new_face.edge2 = new_edge1
      new_face.edge3 = new_edge2
      _MakeCcw( new_face, e11, p )
        
      #Set the adjacent face pointers. */
      for i=0:2
         
	 #Only one NULL link should be set to new_face. */
             if ( !new_edge[i].adjface1 ) 
	                 new_edge[i].adjface1 = new_face
	                 break
             end
             if ( !new_edge[i].adjface2 ) 
	                 new_edge[i].adjface2 = new_face
	                 break
             end
         
       end
        
      return new_face
     end
     _MakeCcw=function(fs,e,p)
      
            if(e.adjface1.visible==true)      
                   fv= e.adjface1
            else fv= e.adjface2
            end
            while true
                for i=0:3
               
                     if( fv.vertex[(i+1) % 3] != e.endpts2 ) 
                                  fs.vertex[0] = e.endpts2
                                  fs.vertex[1] = e.endpts1   
   
                     else                              
                              fs.vertex[0] = e.endpts1 
                              fs.vertex[1] = e.endpts2    
                              _SWAP( s1,fs.edge2,fs.edge3 )
                     end
                 end
                 if fv.vertex[i]==e.endpts1
                      break
                 end
           end
   
             fs.vertex[2]=p
     end
     _MakeFace=function(a,b,c,fold )

                 if( !fold ) 
                            e0,e1,e2
                            tEdge(e0)
                            tEdge(e1)
                            tEdge(e2)  
   
                 else  
                             e0 = fold.edge3
                             e1 = fold.edge2
                             e2 = fold.edge1
                 end
                e0.endpts1 = a              
                e0.endpts2 = a
                e1.endpts1 = b         
                e1.endpts2 = b
                e2.endpts1 = c   
                e2.endpts2 = c

               # Create face for triangle. */
               fss
               fss.edge1= e0  
               fss.edge2= e1
               fss.edge3= e2
               fss.vertex[0] = a  
               fss.vertex[1] = b  
               fss.vertex[2] = c
                                                
                #/* Link edges to face. */
                e0.adjface1= e1.adjface1= e2.adjface1= fss

               return fss
     end
     
     _CleanEdges1=function()

                e = edges
                while true 

                          if ( e.newface )  
	                                 if ( e.adjface1.visible )
	                                      e.adjface1 = e.newface 
                                     else e.adjface2 = e.newface
                                     end
	                                 e.newface = NULL
                          end
                                     
                          e = e.next
                          if (e== edges)
                                break
                          end 
                 end
                          
              

               # Delete any edges marked for deletion. */
                while ( edges && edges.delete ) 
                          e = edges
                          _DELETE( edges, e)
                end
                e = edges.next
                while true 
                         if( e.delete ) 
	                                       t = e
	                                       e = e.next 
                                           _DELETE( edges, t )
                                      
                         else e = e.next
                         end
                         if(e== edges)
                            break
                         end
                end
               
      end
      _CleanFaces=function()

	            
                
                while ( faces && faces.visible ) 
                               f = faces
                               _DELETE( faces, f )
                end
                f = faces.next
                while true
                            if ( f.visible ) 
	                                      t = f
	                                      f = f.next
	                                      _DELETE( faces, t )
                                      
                            else f = f.next
                            end
                            if(f==faces)
                                 break
                            end
                 end
     end
    
     _CleanVertices=function()
        
                 
                e = edges
                while true
                        e.endpts1.onhull = e.endpts2.onhull = ONHULL
                        e = e.next 
                        if(e==edges)
                            break
                        end
                end
                while(vertices && vertices.mark && !vertices.onhull ) 
                         v = vertices 
                         _DELETE( vertices, v)
                end
                v =vertices.next
                while true
                        if ( v.mark && !v.onhull )  
	                            t = v 
	                            v = v.next
                                _DELETE( vertices, t )
                
                        else v = v.next
                        end
                        if (v==vertices)
                                break
                        end
                 end
	 
              
                 v = vertices
                 while true
                      v.duplicate = NULL 
                      v.onhull = !ONHULL
                      v = v.next
                      if (v== vertices)
                                        break
                      end
                 end
              
      end
      _CleanUp=function()

            _CleanEdges1()
            _CleanFaces()
            _CleanVertices()
      end

      _Collinear=function( a, b,c )

        return ( c.z - a.z ) * ( b.y - a.y ) -( b.z - a.z ) * ( c.y - a.y) == 0&&
              ( b.z - a.z ) * ( c.x - a.x ) -( b.x - a.x ) * ( c.z - a.z ) == 0&&
              ( b.x - a.x ) * ( c.y - a.y ) -( b.y  - a.y  ) * ( c.x - a.x ) == 0  
       end

      _Normz=function( f )
          
         a = f.vertex[0]
         b = f.vertex[1]
         c = f.vertex[2]

         return ( b.x - a.x) * ( c.y - a.y ) -( b.y - a.y ) * ( c.x - a.x )
      end
      _Consistency=function()

        e = edges

        while true
         # find index of endpoint[0] in adjacent face[0] */
          for i = 0:(e.adjface1.vertex[i]  != e.endpts1)
      #find index of endpoint[0] in adjacent face[1] */
                 for j = 0:( e.adjface2.vertex[j] != e.endpts1 )
            #check if the endpoints occur in opposite order */
                             if ( !( e.adjface1.vertex[ (i+1) % 3 ] ==e.adjface2.vertex[ (j+2) % 3 ] ||
                             e.adjface1.vertex[ (i+2) % 3 ] == e.adjface2.vertex[ (j+1) % 3 ] ) )
	                                break
                             end
                  end
           end
           e = e.next
         
           if e==edges
                 break
           end

        end

      end
      _Convexity=function( )

              f = faces
   
              while true
                      v = vertices
                      while true
	                            if ( v.mark ) 
	                                     vol = _VolumeSign( f, v )
                                         if ( vol < 0 )
                                                   break
                                         end
                                end
	                            v = v.next
                                if(v==vertices)
                                      break
                                end
                      end
                     f = f.next
                     if f==faces
                         break
                     end

              end

        
      end
      _CheckEuler=function(V, E, F )

             if ( check )
                     println(  "Checks: V, E, F = %d %d %d:\t", V, E, F)
             end
             if ( (V - E + F) != 2 )
                     println( "Checks: V-E+F != 2\n")
             elseif ( check )
                     println( "V-E+F = 2\t")
                  
             end


             if ( F != (2 * V - 4) )
                     println(  "Checks: F=%d != 2V-4=%d  V=%d\n",F, 2*V-4, V)
             elseif ( check ) 
                      println(  "F = 2V-4\t")
                  
             end
   
             if ( (2 * E) != (3 * F) )
                      println(  "Checks: 2E=%d != 3F=%d  E=%d, F=%d\n",2*E, 3*F, E, F )
             elseif ( check ) 
                      println( "2E = 3F\n")
                  
             end
      end
     _Checks=function()

             V=0
             E=0
             F=0

            _Consistency()
            _Convexity()
            if ( v = vertices )
               while true
                    if (v.mark) 
                              V=V+1
	                          v = v.next
                    end
                    if(v==vertices) 
                            break
                    end
                end
            end
           if ( e = edges )
                while true
                     E=E+1
	                 e = e.next
                    if(e==edges)
                        break
                    end
                end
           end
           if (f = faces )
               while true
                          F=F+1
	                      f  = f.next
                    if( f==faces)
                        break
                    end
                end
            end
          _CheckEuler( V, E, F )
    end
    
    if sym ==:Insertar
       function(route)
            file = open(route)
                points= readlines(file)
            close(file)
            sitios= this.spots
            sitios2 = this.spots
            this.s_num = length(points)
            for i=1:this.s_num
                coor= split(points[i]," ")
                sitios.x = parse(BigInt,coor[1])
                sitios.y = parse(BigInt,coor[2])
                sitios.z = parse(BigInt,coor[3])
                if (i < this.s_num)
                    sitios.next = tVertex(next)
                    sitios = sitios.next
                    sitios.prev = sitios2
                    sitios2 = sitios
                else
                    sitios.next = this.spots
                    this.spots.prev = sitios2
                end
            end
            _DoubleTriangle()
            _ConstructHull()
            _LowerFaces()
        end
    elseif sym ==:Plot
         function()
            aux1=this.spots
            x=[]
            y=[]
            z=[]
            while true
                push!(x,aux1.x)
                push!(y,aux1.y)
                push!(z,aux1.z)
                aux1 = aux1.next                
                if(aux1 == this.spots)
                    break
                end
             end
            push!(x,aux1.x)
            push!(y,aux1.y)
            push!(z,aux1.z)
            plotin = plot(x, y,z,color="black",primary = false)
            plotin = scatter!(x,y,z,color="blue",primary = false)
            return plotin
          end
    elseif sym ==:T_DELAUNAY
            function(plot_pol = true)
       
          
            E=0 
            F=0
            V=0

          
           
            temp1= deepcopy(this.spots)
            dual = []
            e=edges
            vor=faces
            fce=[]
            v=vertices
            list=[]
                
                v1=v2=v3=[]
                #vertices
               while true
                    if( v.mark ) 
                         V=V+1         
                         v = v.next
                        push!(list,[v.x,v.y,v.z])
                        
                    end
                    
                    if(v==vertices)
                         break
                    end
                end
                #Caras
               while true
                   F=F+1
                   if(vor.lower)
                       
                           v1=vor.vertex[0].vnum 
                           v2=vor.vertex[1].vnum
                           v3=vor.vertex[2].vnum
                           push!(fce,[[v1.x,v2.x,v3.x],[v1.y,v2.y,v3.y],[v1.z,v2.z,v3.z]])
                        
                    end
                    vor = vor.next
                    
                    if(vor== faces)
                        break
                    end
                end
                while true
                         E=E+1
                         e = e.next
                         push!(dual,[[e.endpts1.x,e.endpts2.x],[e.endpts1.y,e.endpts2.y],[e.endpts1.z,e.endpts2.z]])
                    if ( e== edges)
                        break
                    end
                 end

            this.spots= temp
            if plot_spots
                   plotin = this.Plot()
                   for i=1:length(dual)
                           plotin = plot!(dual[i][1], dual[i][2],dual[i][3],color="red",primary = false)
                   end
                   display(plotin)
             end
             return dual
         end
    else
        getfield(this, sym)

    end

end



    


