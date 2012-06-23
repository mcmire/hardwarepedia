
class Chipset < Reviewable
  def implementations
    Product.find_all_under_chipset(self)
  end
end
