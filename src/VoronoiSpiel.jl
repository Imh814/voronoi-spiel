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

function angle(p0::Punkt, p::Punkt)
    atan(p.y - p0.y, p.x - p0.x)
end

# --- 2. Erstellt das Voronoi-Diagramm aus einer Delaunay-Triangulierung ---
"""
    compute_voronoi_cells_and_edges(D::Delaunay, bounding_pts::Set{Punkt})

Compute the Voronoi diagram from a Delaunay triangulation.
Returns:
  - vor_cells: Dict mapping each site (Punkt) to its Voronoi cell (list of circumcenters, sorted CCW)
  - vor_edges: Vector of tuples (c1, c2), each representing a Voronoi edge

Skips triangles that touch bounding_pts.
"""
function voronoi(D::Delaunay, bounding_pts::Set{Punkt})
    vor_cells = Dict{Punkt, Vector{Punkt}}()
    vor_edges = Vector{Tuple{Punkt,Punkt}}()

    for tri in D.triangles
        e = tri.edge
        for _ in 1:3
            if e.twin !== nothing && e.face !== nothing && e.twin.face !== nothing
                # Check if either triangle touches bounding points
                if any(p -> p in bounding_pts, (e.face.edge.origin,
                                                e.face.edge.next.origin,
                                                e.face.edge.prev.origin)) ||
                   any(p -> p in bounding_pts, (e.twin.face.edge.origin,
                                                e.twin.face.edge.next.origin,
                                                e.twin.face.edge.prev.origin))
                    e = e.next
                    continue
                end

                # Get circumcenters
                c1 = circumcenter(e.face.edge.origin,
                                  e.face.edge.next.origin,
                                  e.face.edge.prev.origin)

                c2 = circumcenter(e.twin.face.edge.origin,
                                  e.twin.face.edge.next.origin,
                                  e.twin.face.edge.prev.origin)

                if e.origin.x < e.twin.origin.x || 
                (e.origin.x == e.twin.origin.x && e.origin.y < e.twin.origin.y)
                    push!(vor_edges, (c1, c2))
                end
            end
            e = e.next
        end
    end

    # Build Voronoi cells per player point
    for tri in D.triangles
        a = tri.edge.origin
        b = tri.edge.next.origin
        c = tri.edge.prev.origin

        # Skip triangles touching bounding points
        if any(p -> p in bounding_pts, (a,b,c))
            continue
        end

        center = circumcenter(a, b, c)

        for p in (a,b,c)
            if !haskey(vor_cells, p)
                vor_cells[p] = Punkt[]
            end
            push!(vor_cells[p], center)
        end
    end

    # Sort vertices CCW for each Voronoi cell
    for (p, verts) in vor_cells
        sort!(verts, by = v -> atan(v.y - p.y, v.x - p.x))
    end

    return vor_cells, vor_edges
end

