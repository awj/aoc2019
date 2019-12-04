module Day2
  # Represent a set of instructions, with an instruction pointer, and
  # utility methods to move the pointer around and modify
  # instructions/arguments.
  class Instructions
    # The full set of instructions
    attr_reader :sequence

    # Pointer (array index) to the current instruction in the set
    attr_accessor :ip

    def initialize(sequence, ip: 0)
      @sequence = sequence
      @ip = ip
    end

    # Operation that the IP currently points to
    def op
      sequence[ip]
    end

    # Access memory at the provided location
    def [](loc)
      sequence[loc]
    end

    # Write memory at the provided location
    def []=(loc, val)
      sequence[loc] = val
    end

    # Read the provided number of instruction args. Omits the current
    # operation.
    def args(count)
      sequence[ip+1, count]
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

  def self.process(codes, noun, verb)
    codesequence = Instructions.new(codes)
    codesequence[1] = noun
    codesequence[2] = verb
    loop do
      op = codesequence.op

      result = interpret(op, codesequence)
      break if result == :finish
    end
    codesequence[0]
  end

  def self.interpret(op, sequence)
    case op
    when 1
      a, b, dest = sequence.args(3)
      sequence[dest] = sequence[a] + sequence[b]
      sequence.increment(4)
      :continue
    when 2
      a, b, dest = sequence.args(3)
      sequence[dest] = sequence[a] * sequence[b]
      sequence.increment(4)
      :continue
    when 99
      :finish
    else
      raise StandardError, "unknown opcode #{op}"
    end
  end
end
