
class Image < ActiveRecord::Base
  belongs_to :reviewable

  attr_accessible :url, :caption
end

