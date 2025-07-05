include("structures.jl")

# Fonction pour créer un triangle
function make_triangle(a::Punkt, b::Punkt, c::Punkt)
    e1 = Kante(a, nothing, nothing, nothing, nothing)
    e2 = Kante(b, nothing, nothing, nothing, nothing)
    e3 = Kante(c, nothing, nothing, nothing, nothing)

    e1.next = e2; e2.next = e3; e3.next = e1
    e1.prev = e3; e2.prev = e1; e3.prev = e2

    tri = Dreieck(e1)

    e1.face = tri
    e2.face = tri
    e3.face = tri

    return tri
end

# Ajouter un triangle dans le set
function add_triangle!(D::Delaunay, t::Dreieck)
    push!(D.triangles, t)
end

# Connecter deux arêtes comme twins
function connect_twin!(e1::Kante, e2::Kante)
    e1.twin = e2
    e2.twin = e1
end

# Tester si un point est à l'intérieur d’un triangle via les aires
function point_in_triangle_area(p::Punkt, a::Punkt, b::Punkt, c::Punkt)
    function area(x::Punkt, y::Punkt, z::Punkt)
        return 0.5 * abs((x.x*(y.y - z.y)) + (y.x*(z.y - x.y)) + (z.x*(x.y - y.y)))
    end
    area_ABC = area(a, b, c)
    area_APB = area(a, p, b)
    area_BPC = area(b, p, c)
    area_APC = area(a, p, c)
    return abs((area_APB + area_BPC + area_APC) - area_ABC) < 1e-8
end

# Trouver le triangle contenant un point
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

# Vérifie si le point opposé à une arête est dans le cercle circonscrit du triangle
function check_umkreis(e::Kante)::Bool
    if e.twin === nothing || e.twin.face === nothing || e.face === nothing
        return false
    end

    a = e.prev.origin
    b = e.origin
    c = e.next.origin

    d_candidates = [
        e.twin.origin,
        e.twin.next.origin,
        e.twin.prev.origin
    ]

    for d in d_candidates
        if d != a && d != b && d != c
            A = [
                a.x  a.y  a.x^2 + a.y^2  1.0;
                b.x  b.y  b.x^2 + b.y^2  1.0;
                c.x  c.y  c.x^2 + c.y^2  1.0;
                d.x  d.y  d.x^2 + d.y^2  1.0;
            ]
            return det(A) > 0.0
        end
    end
    return false
end

# Réalise un flip d'arête
function flip!(e::Kante, D::Delaunay)
    if e.twin === nothing || e.face === nothing || e.twin.face === nothing
        return
    end

    t1 = e.face
    t2 = e.twin.face

    delete!(D.triangles, t1)
    delete!(D.triangles, t2)

    a = e.prev.origin
    b = e.origin
    c = e.next.origin

    d = nothing
    for d_candidate in [e.twin.origin, e.twin.next.origin, e.twin.prev.origin]
        if d_candidate != a && d_candidate != b && d_candidate != c
            d = d_candidate
            break
        end
    end

    tA = make_triangle(a, d, c)
    tB = make_triangle(d, b, c)

    add_triangle!(D, tA)
    add_triangle!(D, tB)

    function find_edge(tri::Dreieck, p1::Punkt, p2::Punkt)
        for i in 1:3
            e = tri.edge
            if e.origin == p1 && e.next.origin == p2
                return e
            end
            tri.edge = tri.edge.next
        end
        error("Edge not found")
    end

    e_ad = find_edge(tA, a, d)
    e_db = find_edge(tB, d, b)
    connect_twin!(e_ad, e_db)

    e_dc = find_edge(tA, d, c)
    e_cd = find_edge(tB, c, d)
    connect_twin!(e_dc, e_cd)

    e_ca = find_edge(tA, c, a)
    e_ac = find_edge(tB, b, c)
    connect_twin!(e_ca, e_ac)
end

# Appelle flip récursivement si nécessaire
function recursive_flip!(e::Kante, D::Delaunay)
    if e === nothing || e.twin === nothing
        return
    end
    if check_umkreis(e)
        flip!(e, D)
        recursive_flip!(e.prev, D)
        recursive_flip!(e.twin.next, D)
    end
end

# Ajoute un point dans la triangulation
function insert_point!(p::Punkt, D::Delaunay)
    tri_old = find_triangle(p, D)

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

    # -- Extraire les arêtes --
    e1 = t1.edge; e2 = e1.next; e3 = e1.prev
    f1 = t2.edge; f2 = f1.next; f3 = f1.prev
    g1 = t3.edge; g2 = g1.next; g3 = g1.prev

    # Connect bp ↔ pb
    e_bp = e1.origin == b && e1.next.origin == p ? e1 : e2.origin == b && e2.next.origin == p ? e2 : e3
    f_pb = f1.origin == p && f1.next.origin == b ? f1 : f2.origin == p && f2.next.origin == b ? f2 : f3
    connect_twin!(e_bp, f_pb)

    # Connect cp ↔ pc
    f_cp = f1.origin == c && f1.next.origin == p ? f1 : f2.origin == c && f2.next.origin == p ? f2 : f3
    g_pc = g1.origin == p && g1.next.origin == c ? g1 : g2.origin == p && g2.next.origin == c ? g2 : g3
    connect_twin!(f_cp, g_pc)

    # Connect ap ↔ pa
    g_ap = g1.origin == a && g1.next.origin == p ? g1 : g2.origin == a && g2.next.origin == p ? g2 : g3
    e_pa = e1.origin == p && e1.next.origin == a ? e1 : e2.origin == p && e2.next.origin == a ? e2 : e3
    connect_twin!(g_ap, e_pa)

    recursive_flip!(e_bp, D)
    recursive_flip!(f_cp, D)
    recursive_flip!(g_ap, D)
end
