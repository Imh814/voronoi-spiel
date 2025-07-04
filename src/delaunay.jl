include("structures.jl")

function point_in_triangle_area(p::Punkt, a::Punkt, b::Punkt, c::Punkt)
    function area(x::Punkt, y::Punkt, z::Punkt)
        return 0.5 * abs( (x.x*(y.y - z.y)) + (y.x*(z.y - x.y)) + (z.x*(x.y - y.y)) )
    end

    area_ABC = area(a,b,c)
    area_APB = area(a,p,b)
    area_BPC = area(b,p,c)
    area_APC = area(a,p,c)
    sum_parts = area_APB + area_BPC + area_APC

    return abs(sum_parts - area_ABC) < 1e-8
end


function find_triangle(p::Punkt, D::Delaunay)
    for t in D.triangles
        e1 = t.edge
        e2 = e1.next
        e3 = e1.prev

        a = e1.origin
        b = e2.origin
        c = e3.origin

        if point_in_triangle_area(p, a, b, c)
            return t
        end
    end
    error("No containing triangle found!")
end

function insert_point!(p::Punkt, D::Delaunay)
    tri_old = first(D.triangles)
    e1 = tri_old.edge
    e2 = e1.next
    e3 = e1.prev
    a = e1.origin
    b = e2.origin
    c = e3.origin
    
    delete!(D.triangles, tri_old)
    
    t1 = make_triangle(a, b, p)
    t2 = make_triangle(b, c, p)
    t3 = make_triangle(c, a, p)

    add_triangle!(D, t1)
    add_triangle!(D, t2)
    add_triangle!(D, t3)

    # Edges متاع t1
    e1 = t1.edge
    e2 = e1.next
    e3 = e1.prev

    # Edges متاع t2
    f1 = t2.edge
    f2 = f1.next
    f3 = f1.prev

    # Edges متاع t3
    g1 = t3.edge
    g2 = g1.next
    g3 = g1.prev

    # --------- bp بين t1 و t2 ---------
    # في t1: b → p
    if e1.origin == b && e1.next.origin == p
        e_bp = e1
    elseif e2.origin == b && e2.next.origin == p
        e_bp = e2
    else
        e_bp = e3
    end

    # في t2: p → b
    if f1.origin == p && f1.next.origin == b
        f_pb = f1
    elseif f2.origin == p && f2.next.origin == b
        f_pb = f2
    else
        f_pb = f3
    end

    connect_twin!(e_bp, f_pb)

    # --------- cp بين t2 و t3 ---------
    # في t2: c → p
    if f1.origin == c && f1.next.origin == p
        f_cp = f1
    elseif f2.origin == c && f2.next.origin == p
        f_cp = f2
    else
        f_cp = f3
    end

    # في t3: p → c
    if g1.origin == p && g1.next.origin == c
        g_pc = g1
    elseif g2.origin == p && g2.next.origin == c
        g_pc = g2
    else
        g_pc = g3
    end

    connect_twin!(f_cp, g_pc)

    # --------- ap بين t3 و t1 ---------
    # في t3: a → p
    if g1.origin == a && g1.next.origin == p
        g_ap = g1
    elseif g2.origin == a && g2.next.origin == p
        g_ap = g2
    else
        g_ap = g3
    end

    # في t1: p → a
    if e1.origin == p && e1.next.origin == a
        e_pa = e1
    elseif e2.origin == p && e2.next.origin == a
        e_pa = e2
    else
        e_pa = e3
    end

    connect_twin!(g_ap, e_pa)


    return
end