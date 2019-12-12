module Day12
  # Represent a point in space, or a force vector.
  class Point
    attr_reader :x, :y, :z

    def initialize(x, y, z)
      @x = x
      @y = y
      @z = z
    end

    def inspect
      "<x=#{x} y=#{y} z=#{z}>"
    end

    alias to_s inspect

    def +(other)
      Point.new(
        x + other.x,
        y + other.y,
        z + other.z
      )
    end

    # Return a force vector that would move this point towards `other`
    # by 1 along each axis
    def %(other)
      Point.new(
        gravity(x, other.x),
        gravity(y, other.y),
        gravity(z, other.z),
      )
    end

    def energy
      x.abs + y.abs + z.abs
    end

    private

    def gravity(v1, v2)
      return 0 if v1 == v2

      v1 < v2 ? 1 : -1
    end
  end

  class Moon
    attr_reader :name, :position, :velocity

    def self.parse(name, line)
      p = line.gsub(/\<|\>/, '').split(", ").map do |chunk|
        chunk.split("=").last.to_i
      end
      new(
        name,
        Point.new(p[0], p[1], p[2]),
        Point.new(0, 0, 0)
      )
    end

    def initialize(name, position, velocity)
      @name = name
      @position = position
      @velocity = velocity
    end

    def inspect
      "#{name}: pos=#{position} vel=#{velocity}"
    end

    alias to_s inspect

    def ==(other)
      name == other.name
    end

    # Handle the gravitational pull of `other` on `self`. (You'll have
    # to call #gravity from `other` for the pull of `self` on `other`)
    def gravity(other)
      @velocity += position % other.position
    end

    def step
      @position += velocity
    end

    def energy
      position.energy * velocity.energy
    end
  end

  module_function

  def simulate(input, steps, debug_steps = nil)
    i = 0
    moons = input.map do |line|
      m = Moon.parse(i, line)
      i += 1
      m
    end

    steps.times do |i|
      if debug_steps && i % debug_steps == 0
        puts "# #{i}"
        puts moons
      end

      moons.each do |moon|
        moons.each do |other|
          next if moon == other

          moon.gravity(other)
        end
      end

      moons.map(&:step)
    end

    moons
  end
end
