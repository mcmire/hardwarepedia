
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

    expose(:sort_key) { params[:sort_key] || session[:sort_key] || "full_name" }

    expose(:sort_order) { params[:sort_order] || session[:sort_order] || "asc" }
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
