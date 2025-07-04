# --- Base Type ---
abstract type Face end

struct Punkt
    x::Float64
    y::Float64
end

# --- Kante ---
mutable struct Kante
    origin::Punkt
    twin::Union{Nothing, Kante}
    next::Union{Nothing, Kante}
    prev::Union{Nothing, Kante}
    face::Union{Nothing, Face}
end



mutable struct Dreieck <: Face
    edge::Kante
end

# --- Delaunay Container ---
mutable struct Delaunay
    triangles::Set{Dreieck}
end

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


function connect_twin!(e1::Kante, e2::Kante)
    e1.twin = e2
    e2.twin = e1
end

function add_triangle!(D::Delaunay, t::Dreieck)
    push!(D.triangles, t)
end

