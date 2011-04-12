class ManufacturersController < ApplicationController
  expose(:manufacturers) { Manufacturer.order_by([:name, :asc]) }
  
  def index
    respond_to do |format|
      format.json { render json: manufacturers }
    end
  end
end