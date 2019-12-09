module Day9

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


end
