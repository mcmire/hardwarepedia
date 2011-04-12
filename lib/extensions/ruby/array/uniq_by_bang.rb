module Enumerable
  # Destructive form of #uniq_by.
  #
  # == Example
  #
  #   arr = [
  #     {:foo => "bar", :zing => "abc"},
  #     {:foo => "bar", :zing => "def"}
  #   ]
  #   arr.uniq_by! {|x| x[:foo] }
  #   arr  #=> {:foo => "bar", :zing => "abc"}
  #
  def uniq_by!(&block)
    replace(uniq_by(&block))
  end
end