module Day5
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
    def [](loc, idx)
      return loc if immediate?(idx)

      sequence[loc]
    end

    # Write memory at the provided location
    def []=(loc, val)
      sequence[loc] = val
    end

    # Is the given argument index an immediate or parameter value?
    #
    # Decided by "op flags", where a 1 indicates immediate and a 0
    # indicates parameter.
    #
    # These flags are to the *left* of the two digits representing an
    # operation, in an opcode.
    #
    # So, for the opcode "1001"
    # * the rightmost two digits are the operation ("01" => addition)
    # * the next digit ("0") indicates the *first* argument is a parameter
    # * the last digit ("1") indicates the *second* argument is immediate
    def immediate?(arg_index)
      flags = op / 100 # trim off operation
      flag = nil
      # 10.divmod(10) => [1, 0] => parameter mode
      # 1.divmod(10) => [0,1] => immediate mode
      # 0.divmod(10) => [0,0] => all further/unspecified flags are parameter mode
      arg_index.times do
        flags, flag = flags.divmod(10)
      end

      flag == 1
    end

    # Read the provided number of instruction args. Omits the current
    # operation.
    def args(count)
      resp = sequence[ip+1, count]
      puts ([op] + resp).inspect
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

  def self.process(codes, input)
    codesequence = Instructions.new(codes)

    output = []

    loop do
      op = codesequence.op

      result = interpret(op, codesequence, input, output)
      break if result == :finish
    end

    output
  end

  def self.interpret(op, sequence, input, output)
    case op % 100
    when 1
      a, b, dest = sequence.args(3)
      a_v = sequence[a,1]
      b_v = sequence[b,2]
      puts "#{a_v} + #{b_v}"
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
      sequence[dest] = input
      sequence.increment(2)
      :continue
    when 4
      loc = sequence.args(1).first
      output << sequence[loc,1]
      sequence.increment(2)
      :continue
    when 99
      :finish
    else
      raise StandardError, "unknown opcode #{op}"
    end
  end
end
