
class ProductsController < ApplicationController
  def_action :index do
    def call
      session[:sort_key] = sort_key
      session[:sort_order] = sort_order
      respond_to do |format|
        format.html
        format.json { render :json => products.map(&:as_json) }
      end
    end

    let(:sort_key) { params[:sort_key] || session[:sort_key] || "full_name" }

    let(:sort_order) { params[:sort_order] || session[:sort_order] || "asc" }

    let(:products) {
      products = Product.all.to_a
      # Schwartzian transform
      sort_rule = _sort_rules[sort_key] or raise "Unknown sort key '#{sort_key}'"
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
    }

    let(:manufacturers) {
      Manufacturer.sort(:name).all
    }

    # don't know if we need this or not:

    def products_by_manufacturer
      products.inject({}) {|h,p| m = manufacturers_by_id[p.manufacturer_id]; (h[m] ||= []) << p; h }
    end

    def manufacturers_by_id
      manufacturers.inject({}) {|h,m| h[m.id] = m; h }
    end

    def _sort_rules
      return {
        "full_name" => "p.full_name.downcase",
        "price" => "p.price",
        "rating_index" => "(p.rating.try(:value) || 0), p.num_reviews"
      }
    end

  end

  def_action :show do
    let(:product) { Product.find_by_webkey(params[:id]) }

    def call
      respond_to do |format|
        format.html
        format.json { render :json => product }
      end
    end
  end
end
