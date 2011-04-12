class ProductsController < ApplicationController
  expose(:manufacturers) { Manufacturer.order_by([:name, :asc]) }
  expose(:manufacturers_by_id) do
    manufacturers.inject({}) {|h,m| h[m.id] = m; h }
  end
  expose(:products) do
    products = Product.all.to_a
    # Schwartzian transform
    tmp = case sort_key
    when "full_name"
      products.map do |p|
        m = manufacturers_by_id[p.manufacturer_id]
        [p, [m.name.downcase, p.full_name.downcase]]
      end
    else
      products.map do |p|
        m = manufacturers_by_id[p.manufacturer_id]
        [p, [m.name.downcase, p.price]]
      end
    end
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
    Product.find(params[:id])
  end
  expose(:sort_key) { params[:sort_key] || "full_name" }
  expose(:sort_order) { params[:sort_order] || "asc" }
  
  def index
    respond_to do |format|
      format.html
      format.json { render json: products.map(&:as_json) }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: product }
    end
  end
end