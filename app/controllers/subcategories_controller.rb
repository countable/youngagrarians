class SubcategoriesController < ApplicationController
  # GET /categories
  # GET /categories.json
  def index
    respond_to do |format|
      @subcategories = Subcategory.all
      format.html
      format.json do
        render json: @subcategories
      end
    end
  end
end
