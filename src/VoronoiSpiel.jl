include("structures.jl")

# --- 1. Berechnet den Umkreismittelpunkt eines Dreiecks ---
function circumcenter(a::Punkt, b::Punkt, c::Punkt)::Punkt
    d = 2 * (a.x*(b.y - c.y) + b.x*(c.y - a.y) + c.x*(a.y - b.y))

    ux = ((a.x^2 + a.y^2)*(b.y - c.y) +
          (b.x^2 + b.y^2)*(c.y - a.y) +
          (c.x^2 + c.y^2)*(a.y - b.y)) / d

    uy = ((a.x^2 + a.y^2)*(c.x - b.x) +
          (b.x^2 + b.y^2)*(a.x - c.x) +
          (c.x^2 + c.y^2)*(b.x - a.x)) / d

    return Punkt(ux, uy)
end

# --- 2. Erstellt das Voronoi-Diagramm aus einer Delaunay-Triangulierung ---
function voronoi(D::Delaunay)
    # Dictionary: Punkt (Spielerzentrum) → Liste von Voronoi-Eckpunkten
    vor_vertices = Dict{Punkt, Vector{Punkt}}()

    for tri in D.triangles
        # Eckpunkte des Dreiecks
        a = tri.edge.origin
        b = tri.edge.next.origin
        c = tri.edge.prev.origin

        # Ignoriere Dreiecke, die zum Bounding-Triangle gehören
        if any(p -> p.x < -999 || p.x > 4000 || p.y < -999 || p.y > 4000, [a, b, c])
            continue
        end

        # Umkreismittelpunkt berechnen
        center = circumcenter(a, b, c)

        # Füge den Mittelpunkt jeder zugehörigen Punkt-Zelle hinzu
        for p in (a, b, c)
            if !haskey(vor_vertices, p)
                vor_vertices[p] = Punkt[]
            end
            push!(vor_vertices[p], center)
        end
    end

    return vor_vertices
end
