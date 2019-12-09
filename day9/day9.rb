load "../intcode.rb"

module Day9
  module_function

  def run(instructions, flag)
    ex = Intcode::Execution.new(instructions, [flag])

    out = []
    loop do
      ex.process do |output|
        puts "output: #{output}"
        out << output
      end
    end
  rescue Intcode::Halt
    out
  end
end
