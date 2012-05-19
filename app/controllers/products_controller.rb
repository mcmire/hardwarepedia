
class ProductsController < ApplicationController
  class Action < ApplicationController
    include FocusedController::Mixin
  end

  class Index < Action
    SORT_RULES = {
      "full_name" => "p.full_name.downcase",
      "price" => "p.price",
      "rating_index" => "(p.rating.try(:value) || 0), p.num_reviews"
    }

    def run
      session[:sort_key] = sort_key
      session[:sort_order] = sort_order
      @products = Product.all
      respond_to do |format|
        format.html
        format.json { render :json => products.map(&:as_json) }
      end
    end

    def sort_key
      @sort_key ||= params[:sort_key] || session[:sort_key] || "full_name"
    end

    def sort_order
      @sort_order ||= params[:sort_order] || session[:sort_order] || "asc"
    end

    def products
      @products ||= begin
        products = Product.all.to_a
        # Schwartzian transform
        sort_rule = SORT_RULES[sort_key] or raise "Unknown sort key '#{sort_key}'"
        tmp = eval <<-RUBY
          products.map do |p|
            m = manufacturers_by_id[p.manufacturer_id]
            [p, [m.name.downcase, #{sort_rule}]]
          end
        RUBY
        case sort_order
          when "desc" then tmp.sort! {|a,b| b[1] <=> a[1] }
          else             tmp.sort! {|a,b| a[1] <=> b[1] }
        end
        tmp.map {|x| x[0] }
      end
    end

    def manufacturers
      Manufacturer.sort(:name).all
    end

    def products_by_manufacturer
      products.inject({}) {|h,p| m = manufacturers_by_id[p.manufacturer_id]; (h[m] ||= []) << p; h }
    end

    def manufacturers_by_id
      manufacturers.inject({}) {|h,m| h[m.id] = m; h }
    end
  end

  class Show < Action
    expose(:product) { Product.find_by_webkey(params[:id]) }

    def run
      respond_to do |format|
        format.html
        format.json { render :json => product }
      end
    end
  end
end
