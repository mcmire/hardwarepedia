class ProductsController < ApplicationController
  SORT_RULES = {
    "full_name" => "p.full_name.downcase",
    "price" => "p.price",
    "rating_index" => "(p.rating.try(:value) || 0), p.num_reviews"
  }
  
  expose(:manufacturers) { Manufacturer.sort(:name).all }
  expose(:manufacturers_by_id) do
    manufacturers.inject({}) {|h,m| h[m.id] = m; h }
  end
  expose(:products) do
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
  expose(:products_by_manufacturer) do
    products.inject({}) {|h,p| m = manufacturers_by_id[p.manufacturer_id]; (h[m] ||= []) << p; h }
  end
  expose(:product) do
    Product.where(:webkey => params[:id]).first
  end
  expose(:sort_key) { session[:sort_key] = params[:sort_key] || session[:sort_key] || "full_name" }
  expose(:sort_order) { session[:sort_order] = params[:sort_order] || session[:sort_order] || "asc" }
  
  def index
    respond_to do |format|
      format.html
      format.json { render :json => products.map(&:as_json) }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render :json => product }
    end
  end
end