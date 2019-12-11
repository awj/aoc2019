require 'set'

module Day10
  module_function

  def slope(point1, point2)
    x1, y1 = point1
    x2, y2 = point2

    x = x2 - x1
    y = y2 - y1

    gcd = x.gcd(y)

    [x / gcd, y / gcd]
  end

  def parse(input)
    asteroids = []
    input.split("\n").each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        asteroids << [x, y] if char == '#'
      end
    end
    asteroids
  end

  def visible_slopes(point, points)
    s = Set.new
    originals = []
    points.each do |p|
      p_slope = slope(point, p)
      unless s.include?(p_slope)
        s << p_slope
        originals << p
      end
    end
    [s, originals]
  end

  # Find the point with the best visibility, along with the *offsets*
  # of every point it can see.
  def best_point(points)
    points.map do |p|
      others = points.reject {|candidate| candidate == p }
      [p, visible_slopes(p, others)]
    end.max_by do |info|
      info[1][0].size
    end
  end

  def order_by_sweep(point, offsets)
    x1, y1 = point
    offsets.sort_by do |off|
      x2, y2 = off
      dx = x2 - x1
      dy = y2 - y1
      Math.atan2(-dx, dy) + Math::PI
    end
  end
end
