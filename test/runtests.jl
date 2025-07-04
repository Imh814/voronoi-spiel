using Test
include("../src/structures.jl")
include("../src/delaunay.jl")

@testset "Point-In-Triangle Tests" begin
    a = Punkt(0, 0)
    b = Punkt(2, 0)
    c = Punkt(1, 2)

    D = Delaunay(Set())
    t0 = make_triangle(a,b,c)
    add_triangle!(D, t0)

    p_inside = Punkt(1, 0.5)
    t_found = find_triangle(p_inside, D)
    @test t_found == t0

    p_inside2 = Punkt(1.1, 1)
    t_found2 = find_triangle(p_inside2, D)
    @test t_found2 == t0

    p_out = Punkt(-1, -1)
    got_error = false
    try
        find_triangle(p_out, D)
    catch e
        got_error = true
    end
    @test got_error == true

    insert_point!(p_inside, D)

    @test length(D.triangles) == 3

    p_new = Punkt(0.5, 0.2)
    t_new = find_triangle(p_new, D)
    @test typeof(t_new) == Dreieck
end
