load "../intcode.rb"

module Day11
  class Robot
    attr_reader :dir, :x, :y, :panels

    def initialize(x: 0, y: 0, panels: Hash.new(0), dir: :up)
      @x = x
      @y = y
      @panels = panels
      @dir = dir
    end

    def paint(num)
      @panels[[x,y]] = num
    end

    def read
      @panels[[x,y]]
    end

    def left
      @dir = case dir
             when :up then :left
             when :left then :down
             when :down then :right
             when :right then :up
             end
    end

    def right
      @dir = case dir
             when :up then :right
             when :right then :down
             when :down then :left
             when :left then :up
             end
    end

    def advance
      case dir
      when :left then @x += 1
      when :right then @x -= 1
      when :up then @y += 1
      when :down then @y -= 1
      end
    end
  end

  module_function

  def paint(instructions, debug: false)
    robot = Robot.new

    input = robot.method(:read)

    exec = Intcode::Execution.new(instructions, input, debug: debug)

    paint = true

    loop do
      exec.process do |color|
        if paint
          robot.paint(color)
          paint = false
        else
          robot.left if color == 0
          robot.right if color == 1
          robot.advance
          paint = true
        end
      end
    end

  rescue Intcode::Halt
    robot
  end

  def identify(instructions, debug: false)
    robot = Robot.new

    robot.paint(1)

    input = robot.method(:read)

    exec = Intcode::Execution.new(instructions, input, debug: debug)

    paint = true

    loop do
      exec.process do |color|
        if paint
          robot.paint(color)
          paint = false
        else
          robot.left if color == 0
          robot.right if color == 1
          robot.advance
          paint = true
        end
      end
    end

  rescue Intcode::Halt
    robot
  end

  def render(robot)
    locations = robot.panels.keys
    xmin = locations.map {|l| l[0] }.sort.first
    xmax = locations.map {|l| l[0] }.sort.last

    ymin = locations.map {|l| l[1] }.sort.first
    ymax = locations.map {|l| l[1] }.sort.last

    (ymin..ymax).reverse_each.map do |line|
      (xmin..xmax).reverse_each.map do |x|
        robot.panels[[x,line]] == 1 ? '#' : ' '
      end.join
    end.join("\n")
  end
end
