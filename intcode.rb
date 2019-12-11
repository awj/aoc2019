module Intcode
  class Halt < StandardError
  end

  # Represent a set of instructions, with an instruction pointer, and
  # utility methods to move the pointer around and modify
  # instructions/arguments.
  class Instructions
    # The full set of instructions
    attr_reader :sequence

    attr_reader :debug

    # Pointer (array index) to the current instruction in the set
    attr_accessor :ip
    # Base for `relative` instructions, which specify a memory
    # location offset from this value
    attr_accessor :relative_base
    # Extended memory beyond initial sequence
    attr_accessor :extended

    FLAG_CODES = {
      0 => :position,
      1 => :immediate,
      2 => :relative
    }.freeze

    def initialize(sequence, ip: 0, relative_base: 0, debug: false)
      @sequence = sequence.dup
      @ip = ip
      @relative_base = relative_base
      @extended = Hash.new(0)
      @debug = debug
    end

    # Operation that the IP currently points to
    def op
      opcode % 100
    end

    def opcode
      sequence[ip]
    end

    def opflags
      opcode / 100
    end

    # Access memory at the provided location. Use `idx` to determine
    # the mode, and return the appropriate value.
    def [](loc, idx)
      case flag(idx)
      when :immediate then loc
      when :position then read(loc)
      when :relative then read(loc + relative_base)
      end
    end

    # Write memory at the provided location. Use `idx` to determine
    # the mode
    def []=(loc, idx, val)
      puts "#{ip} <- #{val}" if debug
      case flag(idx)
      when :position then write(loc, val)
      when :relative then write(loc + relative_base, val)
      else
        raise "flag #{flag(idx)} for assignment"
      end
    end

    # Determine the given argument indexes flag code
    #
    # Decided by "op flags", where a 2 indicates relative, a 1
    # indicates immediate, and a 0 indicates position.
    #
    # These flags are to the *left* of the two digits representing an
    # operation, in an opcode.
    #
    # So, for the opcode "1001"
    # * the rightmost two digits are the operation ("01" => addition)
    # * the next digit ("0") indicates the *first* argument is position
    # * the last digit ("1") indicates the *second* argument is immediate
    def flag(arg_index)
      flags = opflags
      flag = nil
      # 10.divmod(10) => [1, 0] => position mode
      # 1.divmod(10) => [0,1] => immediate mode
      # 0.divmod(10) => [0,0] => all unspecified flags are position mode
      arg_index.times do
        flags, flag = flags.divmod(10)
      end

      FLAG_CODES[flag] || :position
    end

    # Read the provided number of instruction args. Omits the current
    # operation.
    def args(count)
      resp = count.times.map { |i| read(ip + 1 + i) }

      puts(([opcode] + resp).inspect) if debug

      resp
    end

    # Increment the instruction pointer by `count`
    def increment(count)
      @ip += count
    end

    # Assign the instruction pointer to the provided location
    def jump(loc)
      @ip = loc
    end

    def adjust_base(adjustment)
      @relative_base += adjustment
    end

    def read(loc)
      if loc < sequence.size
        sequence[loc]
      else
        extended[loc]
      end
    end

    def write(loc, val)
      if loc < sequence.size
        sequence[loc] = val
      else
        extended[loc] = val
      end
    end
  end

  # Represent a running execution of the intcode interpreter.
  class Execution
    # Input is (currently) exposed so we can pipe in new input by
    # simply appending it to the array.
    attr_accessor :input
    # An `Intcode::Instructions` that this execution is freely able to
    # modify
    attr_accessor :instructions

    # @param [Array<Integer>] codes representing the program data
    # @param [Array<Integer>] input to the execution
    def initialize(codes, input, debug: false)
      @instructions = Instructions.new(codes, debug: debug)
      @input = input
      @debug = debug
    end

    # @yields [Integer] output from the program
    def process
      Intcode.interpret(
        instructions,
        input
      ) do |output|
        puts "output #{output}" if @debug
        yield output
      end
    end
  end

  def self.interpret(sequence, input, &output)
    case sequence.op
    when 1 # add
      a, b, dest = sequence.args(3)
      sequence[dest, 3] = sequence[a,1] + sequence[b,2]
      sequence.increment(4)
    when 2 # mul
      a, b, dest = sequence.args(3)
      sequence[dest, 3] = sequence[a,1] * sequence[b,2]
      sequence.increment(4)
    when 3 # input
      dest = sequence.args(1).first
      sequence[dest, 1] = input.call
      sequence.increment(2)
    when 4 # output
      loc = sequence.args(1).first
      output.call sequence[loc,1]
      sequence.increment(2)
    when 5 # jump n/eq 0
      loc, dest = sequence.args(2)
      if sequence[loc,1] != 0
        sequence.jump(sequence[dest,2])
      else
        sequence.increment(3)
      end
    when 6 # jump eq 0
      loc, dest = sequence.args(2)
      if sequence[loc,1] == 0
        sequence.jump(sequence[dest,2])
      else
        sequence.increment(3)
      end
    when 7 # lt
      a, b, dest = sequence.args(3)
      if sequence[a,1] < sequence[b,2]
        sequence[dest, 3] = 1
      else
        sequence[dest, 3] = 0
      end
      sequence.increment(4)
    when 8 # eql
      a, b, dest = sequence.args(3)
      if sequence[a,1] == sequence[b,2]
        sequence[dest, 3] = 1
      else
        sequence[dest, 3] = 0
      end
      sequence.increment(4)
    when 9 # change relative base
      incr = sequence.args(1).first
      sequence.adjust_base(sequence[incr,1])
      sequence.increment(2)
    when 99 # halt
      raise Halt
    else
      raise StandardError, "unknown opcode #{op}"
    end
  end
end
