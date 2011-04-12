module Enumerable
  # Makes the enumerable a unique collection by calling the given block for each
  # element and using it as a key. Elements with the same key will be collapsed
  # to one element.
  #
  # Note that this is like to_hash_by, but if there are multiple instances of
  # the same element, the first element is kept instead of the last.
  #
  # == Example
  #
  #   arr = [
  #     {:foo => "bar", :zing => "abc"},
  #     {:foo => "bar", :zing => "def"}
  #   ]
  #   arr.uniq_by {|x| x[:foo] }
  #   #=> {:foo => "bar", :zing => "abc"}
  #
  def uniq_by(&block)
    inject(ActiveSupport::OrderedHash.new) {|h,i| h[yield(i)] ||= i; h }.values
  end
end