# Original version of this was not terribly efficient (3.7s for
# slow_advanced_password?, 3.3s for advanced_password?), because I
# generated lists of digits via `candidate.to_s.split("").map(&:to_i)`.
#
# Faster version: (0.38s)
# Ruby provides Integer#digits, which gives us an array of the digits,
# but it comes with least-significant-digit first. Since we don't care
# about machine-independence, just call that good enough and reverse
# the array so we're working with most-significant-digit first, then
# unpack inside the method.
#
# Fastest version: (0.16s)
# Manually perform the work of Integer#digits on the original
# candidate number, storing the results directly in variables so we
# aren't even creating the intermediate array. Instead of using
# Day4.select_candidates, just use range.select
#
# Illegible Fastest version: (0.12s)
# Eliminate all the `return true if` for checks on double numbers in
# favor of one giant hard-to-read boolean expression. This eliminates
# the branching setup around each `if`, and is basically as fast as I
# can make this. Inlining the whole damned thing to avoid method calls
# was somehow *slower*.
module Day4
  module_function

  # Convert each integer in the provided range into an Array of parts
  # values, return the ones where the provided block returns true.
  def select_candidates(range, &block)
    range.select do |candidate|
      parts = candidate.digits.reverse!
      block.call(parts)
    end
  end

  # @param [Array<Integer>] parts is a breakdown of a candidate
  # password into an array of the individual digits, as integers,
  # least significant digit first
  def potential_password?(parts)
    paired = false

    # Walk each pair of digits to check for increasing nature, if at
    # least one pair of digits is equal.
    parts.each_cons(2) do |a, b|
      paired = true if a == b
      return false if b < a
    end

    paired
  end

  def illegible_fastest_advanced_password?(candidate)
    f = candidate % 10
    e = (candidate /= 10) % 10
    d = (candidate /= 10) % 10
    c = (candidate /= 10) % 10
    b = (candidate /= 10) % 10
    a = (candidate /= 10) % 10

    # Bail out early if we aren't in order
    (a > b || b > c || c > d || d > e || e > f) &&

    # Can we find a pair that is equal, but not equal to a surrounding number?
    (a == b && b != c) ||
      (a != b && b == c && c != d) ||
      (b != c && c == d && d != e) ||
      (c != d && d == e && e != f) ||
      (d != e && e == f)
  end

  def fastest_advanced_password?(candidate)
    f = candidate % 10
    e = (candidate /= 10) % 10
    d = (candidate /= 10) % 10
    c = (candidate /= 10) % 10
    b = (candidate /= 10) % 10
    a = (candidate /= 10) % 10

    return false if a > b || b > c || c > d || d > e || e > f

    return true if a == b && b != c
    return true if a != b && b == c && c != d
    return true if b != c && c == d && d != e
    return true if c != d && d == e && e != f
    return true if d != e && e == f

    false
  end

  def advanced_password?(parts)
    a, b, c, d, e, f = parts

    return false if a > b || b > c || c > d || d > e || e > f

    return true if a == b && b != c
    return true if a != b && b == c && c != d
    return true if b != c && c == d && d != e
    return true if c != d && d == e && e != f
    return true if d != e && e == f

    false
  end

  def slow_advanced_password?(parts)
    # Handle edge-of-list cases (e.g. "112345" or "123455")
    double_pair = (
      (parts[0] == parts[1] && parts[1] != parts[2]) ||
        (parts[-1] == parts[-2] && parts[-2] != parts[-3])
    )

    # Walk a sliding window of four digits at a time to see if
    # a) all digits are increasing/same in value
    # b) we can find four digits where the middle two are the same,
    # but do not match the outer two
    parts.each_cons(4) do |a, b, c, d|
      return false if a > b || b > c || c > d

      double_pair = true if a != b && b == c && c != d
    end

    double_pair
  end
end
