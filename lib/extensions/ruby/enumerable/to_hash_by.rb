module Enumerable
  # Converts the enumerable to a hash by calling the given block for each element
  # and using its result value as the key and the element as the value of the hash.
  #
  # Note that this is like uniq_by, but the last duplicate value is kept instead of the first.
  #
  # Example:
  #
  #   arr = [
  #     {:foo => "bar", :zing => "abc"},
  #     {:foo => "bar", :zing => "def"}
  #   ]
  #   arr.uniq_by {|x| x[:foo] }
  #   #=> {:foo => "bar", :zing => "def"}
  #
  def to_hash_by(&block)
    inject(ActiveSupport::OrderedHash.new) {|h,i| h[yield(i)] = i; h }
  end
end