
require_dependency 'reviewable'
require_dependency 'manufacturer'
require_dependency 'image'
require_dependency 'price'
require_dependency 'rating'

module Hardwarepedia
  class Scraper

    class ProductPageScraper
      attr_reader :scraper, :category, :product_page, :product_url

      def initialize(scraper, category, product_page, product_url)
        @scraper = scraper
        @category = category
        @product_page = product_page
        @product_url = product_url

        @retailer = product_page.retailer
      end

      def call
        @scraper.visiting(product_page, product_url, 'product') do |doc|
          @doc = doc

          pairs = doc.xpath('.//div[@id="Specs"]//dl/*').map {|node| node.text.sub(/:$/, "").strip }
          @specs = Hash[*pairs]

          @manufacturer_name = _scrape_manufacturer_name

          # Save the product as soon as possible so that if other threads are
          # processing this same product for some reason, they can see that the
          # product already exists
          @model_name = _scrape_model_name
          @full_name = [@manufacturer_name, @model_name].join(" ")
          @product = _find_or_create_product

          @product.content_urls << product_url
          @product.specs = @specs

          @product.manufacturer = @manufacturer =
            _find_or_create_manufacturer(@manufacturer_name)

          @chipset_manufacturer_name = _scrape_chipset_manufacturer_name
          @chipset_model_name = _scrape_chipset_model_name
          @chipset_manufacturer = _find_or_create_manufacturer(@chipset_manufacturer_name)
          @product.chipset = @chipset = _find_or_create_chipset_product

          # Double check that the product doesn't already exist in the event that
          # it has already been processed in another thread
          logger.debug "Saving product record for #{@product.full_name.inspect}"
          existing_product = Reviewable.find(
            :type => 'product',
            :full_name => @product.full_name
          ).first
          if existing_product
            existing_product.update_attributes(@product.attributes)
            @product = existing_product
          else
            @product.save
          end

          _scrape_images
          _scrape_prices
          _scrape_ratings

          @product.state = 1
          @product.save
        end
      # rescue Error => e
      #   logger.error e
      end

      def _scrape_model_name
        model_name = @specs.delete("Model").to_s.strip
        unless model_name
          raise "Couldn't find model name!\nSpecs are: #{@specs.pretty_inspect}"
        end
        model_name
      end

      def _scrape_manufacturer_name
        manufacturer_name = @specs.delete("Brand").to_s.strip
        if manufacturer_name.blank?
          # Have to do some more sleuthing...
          if node = doc.xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()-1]/a/text()').first
            manufacturer_name = node.text.strip
          end
        end
        if manufacturer_name.blank?
          raise "Couldn't find manufacturer!"
        end
        manufacturer_name
      end

      def _find_or_create_product
        logger.debug "Finding or creating product #{@full_name.inspect}"
        Reviewable.first_or_create(
          {:type => 'product',
           :full_name => @full_name,
           :state => 1},
          {:category => @category,
           :name => @model_name,
           :full_name => @full_name,
           :state => 0}
        )
      end

      def _find_or_create_manufacturer(name)
        Manufacturer.with_or_create(:name, name)
      end

      def _scrape_chipset_manufacturer_name
        chipset_manufacturer_name = @specs.delete("Chipset Manufacturer").to_s.strip
        if chipset_manufacturer_name.blank?
          raise "No chipset manufacturer name found!\nSpecs are: #{@specs.pretty_inspect}"
        end
        chipset_manufacturer_name
      end

      def _scrape_chipset_model_name
        chipset_model_name = @specs.delete("GPU").to_s.strip
        if chipset_model_name.blank?
          raise "No chipset model name found!\nSpecs are: #{@specs.pretty_inspect}"
        end
        chipset_model_name.sub!(%r{\s*\(.+?\)$}, "")
        chipset_model_name
      end

      def _find_or_create_chipset_product
        chipset_full_name = "#{@chipset_manufacturer_name} #{@chipset_model_name}"
        logger.debug "Finding or creating chipset #{chipset_full_name.inspect}"
        # do not reset :state here as we may process two products in a row that
        # point to the same chipset - we will set the :state of the chipset when
        # we actually process it
        Reviewable.first_or_create(
          {:type => 'chipset',
           :full_name => chipset_full_name},
          {:manufacturer => @chipset_manufacturer,
           :category => @category,
           :name => @chipset_model_name}
           # Eventually we will want to copy some of the attributes from this
           # implementation product...
        )
      end

      def _scrape_images
        thumb_links = @doc.xpath('.//ul[contains(@class, "navThumbs")]//a')
        for thumb_link in thumb_links
          # this will give me back xml - i can read the fset element and get dx and dy to get the image dimensions
          "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=fvctx,xml,UTF-8,4&scl=1"
          # this will give me a tile of the image where XXX... is just a random string of chars [0-9A-Za-z_-]
          # and rect is two coords - top left and bottom right
          "http://images17.newegg.com/is/image/newegg/14-125-367-Z01?req=tile&id=XXXXXXXXXXXXXXXXXXXXXX&rect=0,0,1000,1000"

          # Some products have more than four images. If that's true then another
          # thumbnail image will appear on the page that's an ellipsis icon.
          # This image won't have an onmouseover, so we will want to ignore it.
          if thumb_link["onmouseover"]
            thumb_url = thumb_link["onmouseover"].
              # Yes, this really has two d's...
              sub(/^Biz\.Product\.DetailPage\.swapProductImageWithLoadding2011\('/, "").
              sub(/',this\.href,''\);$/, "")
            thumb_url.strip!
            caption = thumb_link["title"].
              sub(/\(Image \d+,New Window\)$/, "")
            caption.strip!
            # We have the url of the thumbnail but we need a url of the entire image
            url = thumb_url.sub(/\?.+$/, "") + "?scl=2.4"
            image = Image.with_or_create(:url, url,
              :reviewable => @product,
              :reviewable_url => @product_url,
              :caption => caption
            )
            @product.images.add(image)
          end
        end
      end

      def _scrape_prices
        # Are you serious...
        sku = @doc.at_xpath('.//div[@id="bcaBreadcrumbTop"]//dd[last()]').
          text.sub(/^Item[ ]*#:[ ]*/, "").to_ascii.strip
        javascript = @scraper.fetch("http://content.newegg.com/LandingPage/ItemInfo4ProductDetail.aspx?Item=#{sku}")
        json = javascript.sub(/^\s*var Product={};\s*var rawItemInfo=/m, "").sub(/;\s*Product=rawItemInfo;\s*$/m, "")
        hash = JSON.parse(json)
        amount = (hash['finalPrice'].to_f * 100).to_i
        price = Price.with_or_create(:reviewable_url, @product_url,
          :reviewable => @product,
          :amount => amount
        )
        @product.prices.add(price)
      end

      def _scrape_ratings
        ratings = []
        # XXX: Should this be itemRating??
        rating_node = @doc.at_xpath('.//div[contains(@class, "grpRating")]//a[contains(@class, "itmRating")]/span')
        # Some products will naturally not have any reviews yet, so there is no rating.
        if rating_node && rating_raw_value = rating_node.text.strip.presence
          num_reviews = rating_node.next.text.scan(/\d+/).first.to_i
          rating = Rating.with_or_create(:reviewable_url, product_url,
            :reviewable => @product,
            :raw_value => rating_raw_value,
            :num_reviews => num_reviews
          )
          @product.ratings.add(rating)
        end
      end
    end

  end
end
