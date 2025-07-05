function distance(p1::Punkt, p2::Punkt)
    return sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
end

function is_colinear(a::Punkt, b::Punkt, c::Punkt)
    return abs((b.y - a.y) * (c.x - b.x) - (c.y - b.y) * (b.x - a.x)) < 1e-8
end
