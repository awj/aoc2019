module Day14
  module_function

  def component(input)
    amount, chemical = input.split(" ")
    [amount.to_i, chemical]
  end

  def load(file)
    parse_dependencies File.read(file).chomp.split("\n")
  end

  def parse_dependencies(input)
    deps = {}
    input.each do |line|
      reqs, result = line.split(" => ")
      result_amount, result_chem = component(result)

      required = reqs.split(", ").map { |req| component(req) }

      deps[result_chem] = {
        yield: result_amount,
        needs: required
      }
    end

    deps
  end

  # Attempt to find the maximum fuel we can generate from a given
  # quantity of ore, using binary search on a range from 0 to
  # max_fuel_cutoff fuel.
  #
  # Printed output is useful, because it seems to usually find the one
  # just _past_ the value we want...
  def max_fuel(input, max_ore, max_fuel_cutoff: 10_000_000)
    (0..max_fuel_cutoff).bsearch do |x|

      ore_cost = fuel_ore_cost(input, needed_fuel: x)
      puts "#{x}: #{ore_cost}"

      max_ore < ore_cost
    end
  end

  def fuel_ore_cost(input, needed_fuel: 1)
    stock = Hash.new(0)

    stock["FUEL"] = -needed_fuel

    needs = ["FUEL"]

    until needs.empty?
      needs.each do |chem|
        info = input[chem]

        yields = info[:yield]
        deps = info[:needs]

        # how many productions do we need to run to get "out of the red"?
        mul = (stock[chem].abs.to_f / yields).ceil
        # run `mul` productions of the chemical, keep any leftovers
        stock[chem] += mul * yields
        # remove `mul` * each requirement from the stock. If this
        # drops the supply of that chemical below 0, we'll generate it
        # next time too.
        deps.each do |req|
          amt, c = req
          stock[c] -= amt * mul
        end
        needs = stock.keys.select { |k| k != "ORE" && stock[k] < 0 }
      end
    end

    stock["ORE"].abs
  end
end
