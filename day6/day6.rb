module Day6
  class Orbitable
    attr_accessor :orbiting
    attr_reader :name, :direct_orbits

    def initialize(name, orbiting = nil)
      @name = name
      @direct_orbits = []
      @orbiting = orbiting
    end

    def add(orbitable)
      orbitable.orbiting = self
      @direct_orbits << orbitable
    end

    def inspect
      orbiters = direct_orbits.map(&:name)
      "#<Day6::Orbitable @name=#{name} @orbiting=#{orbiters}>"
    end

    def ==(other)
      return false if other.nil?
      name == other.name
    end

    def parents
      return [] if orbiting.nil?

      orbiting.parents + [orbiting]
    end

    def all_orbiters
      direct_orbits + direct_orbits.flat_map(&:all_orbiters)
    end

    def total_orbits(parents = 0)
      parents + direct_orbits.sum { |o| o.total_orbits(parents + 1) }
    end
  end

  module_function

  def construct_orbits(specs)
    orbits = {}

    specs.each do |spec|
      orbited_name, orbiteer_name = spec.split(")")
      orbited = orbits[orbited_name] || Orbitable.new(orbited_name)
      orbiteer = orbits[orbiteer_name] || Orbitable.new(orbiteer_name)

      orbits[orbited_name] = orbited
      orbits[orbiteer_name] = orbiteer

      orbited.add orbiteer
    end

    orbits
  end

  def root(orbits)
    orbits.values.find {|o| o.orbiting.nil? }
  end

  def common_root(o1_parents, o2_parents)
    o1_parents.zip(o2_parents).take_while do |c1, c2|
      c1 == c2
    end.last[0]
  end

  def diverging_paths(o1_parents, o2_parents)
    root = common_root(o1_parents, o2_parents)

    [
      o1_parents.drop_while { |o| o != root },
      o2_parents.drop_while { |o| o != root }
    ]
  end

  def transfers(o1, o2)
    o1_path = o1.parents
    o2_path = o2.parents

    diverging_paths(o1_path, o2_path).sum(&:size) - 2
  end
end
