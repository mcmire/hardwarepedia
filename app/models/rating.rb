
require_dependency 'site'
require_dependency 'reviewable'

class Rating < Sequel::Model
  include Base

  # TODO: When we add merchants then we need a link to merchant-product
  # and we can get possibly get rid of reviewable_url

  many_to_one :reviewable

  def before_save
    super
    # interpret raw value
    if raw_value =~ %r{/}
      num, den = raw_value.split("/")
      self.value = ((num.to_f / den.to_f) * 100).round
    else
      self.value = raw_value.to_i   # ??
    end
  end

  def site_name
    @site_name ||= begin
      host = URI.parse(reviewable_url).host.sub(%r{^www\.}, "")
      Site.find_by_host(host).name
    end
  end
end
