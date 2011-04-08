#!/usr/bin/env ruby

ENV["GEM_PATH"] = "vendor/ruby/1.9.1"

require 'pp'
require 'uri'
require 'nokogiri'
require 'patron'
require 'yajl'

TEMP_DIR = "/tmp/hardwarepedia"
CONTENT_CACHE_FILE = "#{TEMP_DIR}/content_cache.yml"

FileUtils.mkdir_p(TEMP_DIR)
if File.exists?(CONTENT_CACHE_FILE)
  CONTENT_CACHE = YAML.load_file(CONTENT_CACHE_FILE)
else
  CONTENT_CACHE = {}
end

at_exit do
  File.open(CONTENT_CACHE_FILE, "w") {|f| YAML.dump(CONTENT_CACHE, f) } if CONTENT_CACHE
end

def fetch(uri)
  CONTENT_CACHE[uri] || begin
    url = URI.parse(uri)
    session = Patron::Session.new
    session.base_url = "#{url.scheme}://#{url.host}"
    full_path = url.path + (url.query ? "?#{url.query}" : "")
    puts "Fetching #{uri}..."
    resp = session.get(full_path)
    CONTENT_CACHE[uri] = resp.body
    resp.body
  end
end

def visit(url)
  Nokogiri.parse(fetch(url))
end

def mine
  category = "Graphics Cards"
  doc = visit("http://www.newegg.com/Store/SubCategory.aspx?SubCategory=48&name=Desktop-Graphics-Video-Cards")
  links = doc.xpath("//span[contains(@class, 'itemDescription')]/parent::a")
  links.each do |link|
    product_attrs = {
      :category => category,
      :purchase_urls => [],
      :images => []
    }
    product_url = link["href"]
    product_attrs[:purchase_urls] << product_url
    
    doc2 = visit(product_url)
    
    values = doc2.xpath('//div[@id="Specs"]//dl/dt | //div[@id="Specs"]//dl/dd').map {|node| node.text }
    specs = product_attrs[:specs] = Hash[*values]
    product_attrs[:manufacturer] = specs.delete("Brand")
    product_attrs[:model] = specs.delete("Model")
    
    # Are you serious
    sku = doc2.at_xpath('//div[@id="bcaBreadcrumbTop"]//dd[last()]').text.sub(/^Item[ ]*#:[ ]*/, "")[1..-1]
    javascript = fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
    json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
    hash = Yajl::Parser.parse(json)
    product_attrs[:price] = hash["finalPrice"]
    
    rating_node = doc2.at_xpath('//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
    product_attrs[:rating] = rating_node.text
    num_reviews_node = rating_node.next
    product_attrs[:num_reviews] = num_reviews_node.text.scan(/\d+/).first
    
    img = doc2.at_xpath('//img[@id="mainSlide_0"]')
    product_attrs[:images] << {
      :url => img["src"],
      :caption => img["title"]
    }
    
    pp product_attrs
    exit
  end
end

mine