
require_dependency 'reviewable'

class Image < Sequel::Model
  include Base
  many_to_one :reviewable
end

