class CategoriesController < InheritedResources::Base
  def create
    create! do |success, failure|
      success.html do
        flash[:success] = "#{resource_class} successfully added."
        redirect_to categories_path
      end
    end
  end
  
  def update
    update! do |success, failure|
      success.html do
        flash[:success] = "#{resource_class} successfully updated."
        redirect_to categories_path
      end
    end
  end
  
  def delete
    @category = Category.find(params[:id])
  end
  
  def destroy
    destroy! do |success, failure|
      success.html do
        flash[:success] = "#{resource_class} successfully deleted."
        redirect_to categories_path
      end
    end
  end
end
