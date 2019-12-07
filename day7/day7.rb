module Day7
  class Halt < StandardError
  end

  # Represent a set of instructions, with an instruction pointer, and
  # utility methods to move the pointer around and modify
  # instructions/arguments.
  class Instructions
    # The full set of instructions
    attr_reader :sequence

    # Pointer (array index) to the current instruction in the set
    attr_accessor :ip

    def initialize(sequence, ip: 0)
      @sequence = sequence.dup
      @ip = ip
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
    # if this is immediate or position mode, and return the
    # appropriate value.
    def [](loc, idx)
      return loc if immediate?(idx)

      sequence[loc]
    end

    # Write memory at the provided location
    def []=(loc, val)
      sequence[loc] = val
    end

    # Is the given argument index an immediate or position value?
    #
    # Decided by "op flags", where a 1 indicates immediate and a 0
    # indicates position.
    #
    # These flags are to the *left* of the two digits representing an
    # operation, in an opcode.
    #
    # So, for the opcode "1001"
    # * the rightmost two digits are the operation ("01" => addition)
    # * the next digit ("0") indicates the *first* argument is position
    # * the last digit ("1") indicates the *second* argument is immediate
    def immediate?(arg_index)
      flags = opflags
      flag = nil
      # 10.divmod(10) => [1, 0] => position mode
      # 1.divmod(10) => [0,1] => immediate mode
      # 0.divmod(10) => [0,0] => all unspecified flags are position mode
      arg_index.times do
        flags, flag = flags.divmod(10)
      end

      flag == 1
    end

    # Read the provided number of instruction args. Omits the current
    # operation.
    def args(count)
      resp = sequence[ip+1, count]
      puts ([opcode] + resp).inspect
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
  end

  class Execution
    attr_accessor :input, :instructions

    def initialize(codes, input)
      @instructions = Instructions.new(codes)
      @input = input
    end

    def process
      Day7.interpret(
        instructions,
        input
      ) do |output|
        yield output
      end
    end
  end

  def self.process_chained_amplifiers(codes, weights)
    weights.to_a.permutation.map do |config|
      machines = config.map do |weight|
        Execution.new(codes, [weight])
      end

      i = 0
      machines[0].input << 0
      final_output = nil

      begin
        loop do
          puts "machine: #{i}"
          machines[i].process do |output|
            final_output = output
            i = (i + 1) % machines.size
            machines[i].input << output
          end
        end
      rescue Halt
      end

      final_output
    end.max
  end

  def self.interpret(sequence, input, &output)
    case sequence.op % 100
    when 1
      a, b, dest = sequence.args(3)
      sequence[dest] = sequence[a,1] + sequence[b,2]
      sequence.increment(4)
      :continue
    when 2
      a, b, dest = sequence.args(3)
      sequence[dest] = sequence[a,1] * sequence[b,2]
      sequence.increment(4)
      :continue
    when 3
      dest = sequence.args(1).first
      sequence[dest] = input.shift
      sequence.increment(2)
      :continue
    when 4
      loc = sequence.args(1).first
      output.call sequence[loc,1]
      sequence.increment(2)
      :continue
    when 5
      loc, dest = sequence.args(2)
      if sequence[loc,1] != 0
        sequence.jump(sequence[dest,2])
      else
        sequence.increment(3)
      end
      :continue
    when 6
      loc, dest = sequence.args(2)
      if sequence[loc,1] == 0
        sequence.jump(sequence[dest,2])
      else
        sequence.increment(3)
      end
      :continue
    when 7
      a, b, dest = sequence.args(3)
      if sequence[a,1] < sequence[b,2]
        sequence[dest] = 1
      else
        sequence[dest] = 0
      end
      sequence.increment(4)
      :continue
    when 8
      a, b, dest = sequence.args(3)
      if sequence[a,1] == sequence[b,2]
        sequence[dest] = 1
      else
        sequence[dest] = 0
      end
      sequence.increment(4)
      :continue
    when 99
      raise Halt
      :finish
    else
      raise StandardError, "unknown opcode #{op}"
    end
  end
end
