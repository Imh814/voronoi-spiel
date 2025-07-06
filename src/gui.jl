using Plots
using Colors
using GtkObservables
using GtkObservables.Gtk4


include("structures.jl")
include("game.jl")

# Visualisiert das Voronoi-Diagramm mit den Punkten beider Spieler
using Plots

"""
    plot_voronoi(vor_cells, vor_edges, player1, player2, dummy_points)

Plots the Voronoi diagram:
- player cells are filled with color
- Voronoi vertices as green diamonds
- Voronoi edges as black lines
- player points as circles/stars
"""
function plot_voronoi(vor_cells::Dict{Punkt, Vector{Punkt}}, 
                      vor_edges::Vector{Tuple{Punkt, Punkt}}, 
                      player1::Player, 
                      player2::Player, 
                      dummy_points::Vector{Punkt})

    plt = plot(aspect_ratio=:equal, legend=false, size=(800,800), grid=false)

    # Plot each player cell
    for (site, polygon) in vor_cells
        if site in dummy_points
            continue
        end

        # Determine color
        color = :gray
        if site in player1.points
            color = player1.color
        elseif site in player2.points
            color = player2.color
        end

        xs = [p.x for p in polygon]
        ys = [p.y for p in polygon]

        # Close polygon
        push!(xs, polygon[1].x)
        push!(ys, polygon[1].y)

        plot!(xs, ys, seriestype=:shape, fillalpha=0.4, c=color, linecolor=:black)
    end

    # Plot Voronoi edges
    for (c1, c2) in vor_edges
        plot!([c1.x, c2.x], [c1.y, c2.y], color=:black, lw=1)
    end

    # Plot Voronoi vertices
    vor_vertices = [v for verts in values(vor_cells) for v in verts]
    scatter!([v.x for v in vor_vertices], [v.y for v in vor_vertices],
             color=:green, marker=:diamond, markersize=4)

    # Plot player points
    scatter!([p.x for p in player1.points],
             [p.y for p in player1.points],
             color=player1.color,
             marker=:circle,
             markersize=6)

    scatter!([p.x for p in player2.points],
             [p.y for p in player2.points],
             color=player2.color,
             marker=:star5,
             markersize=6)

    display(plt)
end





function clip_polygon_to_rect(polygon::Vector{Punkt}, xmin::Float64, xmax::Float64, ymin::Float64, ymax::Float64)
    # Convert to tuples for easier math
    poly = [(p.x, p.y) for p in polygon]

    function inside(p, edge)
        x, y = p
        edge == :left   && return x >= xmin
        edge == :right  && return x <= xmax
        edge == :bottom && return y >= ymin
        edge == :top    && return y <= ymax
    end

    function intersect(p1, p2, edge)
        x1, y1 = p1
        x2, y2 = p2
        if edge == :left
            x = xmin
            y = y1 + (y2-y1)*(xmin-x1)/(x2-x1)
        elseif edge == :right
            x = xmax
            y = y1 + (y2-y1)*(xmax-x1)/(x2-x1)
        elseif edge == :bottom
            y = ymin
            x = x1 + (x2-x1)*(ymin-y1)/(y2-y1)
        elseif edge == :top
            y = ymax
            x = x1 + (x2-x1)*(ymax-y1)/(y2-y1)
        end
        return (x,y)
    end

    for edge in [:left, :right, :bottom, :top]
        output = []
        n = length(poly)
        for i in 1:n
            curr = poly[i]
            prev = poly[mod1(i-1,n)]
            if inside(curr, edge)
                if !inside(prev, edge)
                    push!(output, intersect(prev, curr, edge))
                end
                push!(output, curr)
            elseif inside(prev, edge)
                push!(output, intersect(prev, curr, edge))
            end
        end
        poly = output
    end

    return [Punkt(x,y) for (x,y) in poly]
end
