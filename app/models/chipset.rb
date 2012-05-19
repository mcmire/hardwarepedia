
class Chipset < Reviewable
  has_many :implementations, :class_name => "Product"
end
