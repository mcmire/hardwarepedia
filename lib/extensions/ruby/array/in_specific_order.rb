class Array
  # This method lets you put an array of elements in a very specific
  # order, by some value in each element.
  #
  # === Examples
  #
  #   records = [
  #     Model.new(:id => 1),
  #     Model.new(:id => 2),
  #     Model.new(:id => 3)
  #   ]
  #   records.in_specific_order(2, 1, 3, &:id)
  #   #=> [
  #     Model.new(:id => 2),
  #     Model.new(:id => 1),
  #     Model.new(:id => 3)
  #   ]
  #
  #   hashes = [
  #     {:foo => "biz"},
  #     {:foo => "baz"},
  #     {:foo => "buz"}
  #   ]
  #   hashes.in_specific_order("baz", "buz", "biz") {|hash| hash[:foo] }
  #   #=> [
  #     {:foo => "baz"},
  #     {:foo => "buz"},
  #     {:foo => "biz"}
  #   ]
  #
  def in_specific_order(*values, &block)
    to_hash_by(&block).values_at(*values.flatten).compact
  end
end