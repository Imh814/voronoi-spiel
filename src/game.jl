include("structures.jl")
include("delaunay.jl")

# Repräsentiert einen Spieler mit Namen und Farbe
struct Player
    name::String
    color::Symbol
    points::Vector{Punkt}
end

# Initialisiert das Spiel mit Bounding-Triangle und Spielern
# Spiel initialisieren
function start_game(k::Int)
    # Bounding-Triangle (groß genug, um Spielfeld zu umschließen)
    a = Punkt(-2000.0, -2000.0)
    b = Punkt(7000.0, -2000.0)
    c = Punkt(2500.0, 7000.0)

    bounding_pts = Set([a, b, c])   # Save bounding points explicitly
    bounding = make_triangle(a, b, c)

    D = Delaunay(Set([bounding]))

    # Zwei Spieler
    player1 = Player("Spieler A", :blue, Punkt[])
    player2 = Player("Spieler B", :red, Punkt[])

    return D, player1, player2, bounding_pts
end


# Fügt einen Punkt vom Spieler hinzu
function play_turn!(player::Player, p::Punkt, D::Delaunay)
    push!(player.points, p)
    insert_point!(p, D)
end

# Berechnet die Fläche einer Voronoi-Zelle durch Polygonfläche
function polygon_area(poly::Vector{Punkt})
    n = length(poly)
    area = 0.0
    for i in 1:n
        p1 = poly[i]
        p2 = poly[mod1(i + 1, n)]
        area += (p1.x * p2.y - p2.x * p1.y)
    end
    return abs(area) / 2.0
end

# Berechnet, wie viel Fläche jeder Spieler kontrolliert
function calculate_areas(vor::Dict{Punkt, Vector{Punkt}}, player1::Player, player2::Player)
    area1 = 0.0
    area2 = 0.0
    for (p, poly) in vor
        a = polygon_area(poly)
        if p in player1.points
            area1 += a
        elseif p in player2.points
            area2 += a
        end
    end
    return area1, area2
end

# Gibt den Gewinner basierend auf kontrollierter Fläche zurück
function winner(area1::Float64, area2::Float64, player1::Player, player2::Player)
    if area1 > area2
        return player1.name * " gewinnt mit " * string(round(area1, digits=2)) * " gegen " * string(round(area2, digits=2))
    elseif area2 > area1
        return player2.name * " gewinnt mit " * string(round(area2, digits=2)) * " gegen " * string(round(area1, digits=2))
    else
        return "Unentschieden!"
    end
end
