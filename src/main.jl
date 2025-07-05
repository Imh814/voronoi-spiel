
include("structures.jl")
include("delaunay.jl")
include("VoronoiSpiel.jl")
include("game.jl")
include("gui.jl")   # 👉 maintenant on active l'affichage

function main()
    # Anzahl der Punkte pro Spieler
    k = 3

    # Initialisiere Spiel und Delaunay-Triangulierung
    D, player1, player2 = start_game(k)

    # Beispielpunkte (du kannst das später dynamisch machen)
    points1 = [Punkt(100.0, 100.0), Punkt(300.0, 200.0), Punkt(150.0, 400.0)]
    points2 = [Punkt(500.0, 100.0), Punkt(450.0, 300.0), Punkt(400.0, 450.0)]

    # Abwechselnd Punkte einfügen
    for i in 1:k
        play_turn!(player1, points1[i], D)
        play_turn!(player2, points2[i], D)
    end

    # Erzeuge Voronoi-Diagramm
    V = voronoi(D)

    # Berechne Flächenanteile der Spieler
    area1, area2 = calculate_areas(V, player1, player2)

    # Gewinner anzeigen
    println(winner(area1, area2, player1, player2))

    # 👉 Jetzt: Visualisierung anzeigen
    plot_voronoi(V, player1, player2)
end

main()
