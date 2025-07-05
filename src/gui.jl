using Plots
using Colors
using GtkObservables
using GtkObservables.Gtk4
using GtkObservables.CairoMakie


include("structures.jl")
include("game.jl")

# Visualisiert das Voronoi-Diagramm mit den Punkten beider Spieler
function plot_voronoi(vor_dict::Dict{Punkt, Vector{Punkt}}, player1::Player, player2::Player)
    # Erstelle leeres Plot-Fenster mit quadratischem Seitenverhältnis
    plt = plot(aspect_ratio=:equal, legend=false, size=(700, 700), grid=false)

    for (center, polygon) in vor_dict
        # Bestimme die Farbe je nachdem, welchem Spieler der Punkt gehört
        if center in player1.points
            color = player1.color
        elseif center in player2.points
            color = player2.color
        else
            color = :gray  # z.B. für neutrale Zellen oder Bounding-Triangle (sollte ignoriert werden)
        end

        # Extrahiere die x- und y-Koordinaten der Polygonpunkte
        xs = [p.x for p in polygon]
        ys = [p.y for p in polygon]

        # Schließe das Polygon durch Rückkehr zum Startpunkt
        push!(xs, polygon[1].x)
        push!(ys, polygon[1].y)

        # Zeichne die gefüllte Zelle mit schwarzer Umrandung
        plot!(xs, ys, seriestype=:shape, fillalpha=0.4, c=color, linecolor=:black)
    end

    # Zeichne Spieler 1 Punkte (Kreise)
    scatter!([p.x for p in player1.points],
             [p.y for p in player1.points],
             color=player1.color,
             label=player1.name,
             markersize=6,
             marker=:circle)

    # Zeichne Spieler 2 Punkte (Sterne)
    scatter!([p.x for p in player2.points],
             [p.y for p in player2.points],
             color=player2.color,
             label=player2.name,
             markersize=6,
             marker=:star5)

    # Anzeige des Plots
    display(plt)
end
