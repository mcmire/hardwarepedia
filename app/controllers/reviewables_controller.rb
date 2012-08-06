
class ReviewablesController < ApplicationController
  def_action :index do
    expose(:manufacturers) { Manufacturer.order(:name).all }
    expose(:sort_key) { params[:sort_key] || session[:sort_key] || "full_name" }
    expose(:sort_order) { params[:sort_order] || session[:sort_order] || "asc" }

    def call
      session[:sort_key] = sort_key
      session[:sort_order] = sort_order
      respond_to do |format|
        format.html
        format.json { render :json => reviewables.map(&:as_json) }
      end
    end
  end

  def_action :show do
    expose(:reviewable) { Reviewable.first(:webkey => params[:webkey]) }

    def call
      if reviewable
        respond_to do |format|
          format.html
          format.json { render :json => reviewable }
        end
      else
        not_found! "Could not find a reviewable matching webkey #{params[:webkey].inspect}."
      end
    end
  end
end
