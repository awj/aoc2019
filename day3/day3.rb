module Day3
  module_function

  def setup(input)
    grid = Hash.new

    input.each_with_index do |line, i|
      lay_path(grid, i, line)
    end

    grid
  end

  def lay_path(grid, wire, pathstr)
    loc = [0,0]
    steps = 0

    pathstr.split(",").each do |p|
      loc, steps = place_wire(grid, wire, loc, p, steps)
    end
  end

  def self.intersections(grid)
    grid.select do |k,v| v.length > 1 end
  end

  def self.closest(grid)
    grid.min_by do |pos|
      manhattan(pos, [0,0])
    end
  end

  def self.place_wire(grid, wire, start, path, steps)
    mag = path[1, path.length].to_i

    move = case path[0]
           when "R"
             -> (pos) { [pos[0] - 1, pos[1]] }
           when "L"
             -> (pos) { [pos[0] + 1, pos[1]] }
           when "U"
             -> (pos) { [pos[0], pos[1] + 1] }
           when "D"
             -> (pos) { [pos[0], pos[1] - 1] }
           end

    pos = start.dup

    mag.times do
      steps += 1
      pos = move.call(pos)
      grid[pos] = {} if grid[pos].nil?

      unless grid[pos][wire]
        grid[pos][wire] = steps
      end
    end

    [pos, steps]
  end

  def self.manhattan(p1, p2)
    x1, y1 = p1
    x2, y2 = p2

    (x1 - x2).abs + (y1 - y2).abs
  end
end
