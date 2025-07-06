
include("structures.jl")
include("delaunay.jl")
include("VoronoiSpiel.jl")
include("game.jl")
include("gui.jl")

function main()
    # Anzahl der Punkte pro Spieler
    k = 3

    # Initialisiere Spiel und Delaunay-Triangulierung
    D, player1, player2, bounding_pts = start_game(k)

    dummy_points = [
    Punkt(0.0, 0.0),
    Punkt(500.0, 0.0),
    Punkt(0.0, 500.0),
    Punkt(500.0, 500.0)
    ]

    for dp in dummy_points
        insert_point!(dp, D)
    end


    # Beispielpunkte (du kannst das später dynamisch machen)
    points1 = [Punkt(150.0, 150.0), Punkt(300.0, 250.0), Punkt(200.0, 350.0)]
    points2 = [Punkt(350.0, 150.0), Punkt(400.0, 300.0), Punkt(300.0, 400.0)]


    # Abwechselnd Punkte einfügen
    for i in 1:k
        play_turn!(player1, points1[i], D)
        play_turn!(player2, points2[i], D)
    end

    dummy_points_set = Set(dummy_points)

    # Erzeuge Voronoi-Diagramm
    vor_cells, vor_edges = voronoi(D,bounding_pts)

    # Berechne Flächenanteile der Spieler
    area1, area2 = calculate_areas(vor_cells, player1, player2)

    # Gewinner anzeigen
    println(winner(area1, area2, player1, player2))

    # 👉 Jetzt: Visualisierung anzeigen
    plot_voronoi(vor_cells,vor_edges, player1, player2, dummy_points)

end

main()
