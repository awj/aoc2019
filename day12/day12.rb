require 'set'
require 'time'

module Day12
  class Moon
    attr_reader :name, :position, :velocity

    attr_accessor :impacting_positions

    def self.parse(name, line)
      p = line.gsub(/\<|\>/, '').split(", ").map do |chunk|
        chunk.split("=").last.to_i
      end
      new(
        name,
        p,
        [0,0,0]
      )
    end

    def initialize(name, position, velocity)
      @name = name
      @position = position
      @velocity = velocity
    end

    def inspect
      "#{name}: pos=[#{position[0]},#{position[1]},#{position[2]}] vel=[#{velocity[0]},#{velocity[1]},#{velocity[2]}]"
    end

    alias to_s inspect

    def tag
      [position.hash, velocity.hash]
    end

    def ==(other)
      name == other.name
    end

    # Handle the gravitational pull of `other` on `self`. (You'll have
    # to call #gravity from `other` for the pull of `self` on `other`)
    def gravity
      impacting_positions.each do |other_position|
        # Reuse `x <=> y` to get "how will y move to get to x". Has the following cases:
        # x <=> y when x == y => 0
        # x <=> y when x < y => -1
        # x <=> y when x > y => 1
        # Note the flipping of position / other position
        @velocity[0] += other_position[0] <=> @position[0]
        @velocity[1] += other_position[1] <=> @position[1]
        @velocity[2] += other_position[2] <=> @position[2]
      end
    end

    def step
      @position[0] += @velocity[0]
      @position[1] += @velocity[1]
      @position[2] += @velocity[2]
    end

    def energy
      position.sum * velocity.sum
    end
  end

  class System
    attr_reader :moons

    def initialize(moons)
      @moons = moons
    end

    def inspect
      moons.join(",")
    end
    alias to_s inspect

    def x_tag
      [
        moons.map(&:position).map {|p| p[0] },
        moons.map(&:velocity).map {|p| p[0] },
      ]
    end

    def y_tag
      [
        moons.map(&:position).map {|p| p[1] },
        moons.map(&:velocity).map {|p| p[1] },
      ]
    end

    def z_tag
      [
        moons.map(&:position).map {|p| p[2] },
        moons.map(&:velocity).map {|p| p[2] },
      ]
    end
    
    def step
      moons.map(&:gravity)
      moons.map(&:step)
    end

    def energy
      moons.map(&:energy).sum
    end
  end

  module_function

  def parse(input)
    i = 0
    moons = input.map do |line|
      m = Moon.parse(i, line)
      i += 1
      m
    end

    moons.each do |m|
      m.impacting_positions = (moons - [m]).map(&:position)
    end

    System.new(moons)
  end

  def simulate(input, steps, debug_steps = nil)
    system = parse(input)

    steps.times do |i|
      if debug_steps && i % debug_steps == 0
        puts "# #{i}"
        puts system.moons
      end

      system.step
    end

    system
  end

  def recurrence(input, max_steps: nil, debug_steps: nil)
    i = 0

    system = parse(input)

    t = Time.now

    x_cycles, x_starting = [-1, system.x_tag]
    y_cycles, y_starting = [-1, system.y_tag]
    z_cycles, z_starting = [-1, system.z_tag]

    loop do
      break if max_steps && i >= max_steps

      if debug_steps && i % debug_steps == 0
        rate = Time.now - t
        puts "#{i} (#{i.to_f / rate}/s)"
      end

      system.step

      i += 1

      x_cycles = i if x_cycles == -1 && x_starting == system.x_tag
      y_cycles = i if y_cycles == -1 && y_starting == system.y_tag
      z_cycles = i if z_cycles == -1 && z_starting == system.z_tag

      break if x_cycles != -1 && y_cycles != -1 && z_cycles != -1
    end

    [x_cycles, y_cycles, z_cycles]
  end
end
