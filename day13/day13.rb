load "../intcode.rb"

module Day13
  module_function

  def execute(game)
    map = {}

    output = []

    exec = Intcode::Execution.new(game, nil)

    loop do
      exec.process do |out|
        output << out

        if output.size == 3
          if x == -1 && y == 0
            puts "score: #{tile}, blocks: #{map.values.count {|v| v == 2}}"
          else
            x, y, tile = output
            map[[x,y]] = tile
            output = []
          end
        end

        if output.size > 3
          raise "oh no!"
        end
      end
    end

  rescue Intcode::Halt
    map
  end

  def play(game)
    game = game.dup
    game[0] = 2

    map = {}

    output = []

    input = lambda do
      ball = map.select do |k, v|
        v == 4
      end.first.first

      paddle = map.select do |k, v|
        v == 3
      end.first.first

      if ball[0] > paddle[0]
        1
      elsif ball[0] < paddle[0]
        -1
      else
        0
      end
    end

    exec = Intcode::Execution.new(game, input)

    loop do
      exec.process do |out|
        output << out

        if output.size == 3
          x, y, tile = output
          if x == -1 && y == 0
            puts "score: #{tile}, blocks: #{map.values.count {|v| v == 2}}"
          else
            map[[x,y]] = tile
          end
          output = []
        end

        if output.size > 3
          raise "oh no!"
        end
      end
    end

  rescue Intcode::Halt
    map
  end
end
