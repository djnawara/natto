class ContactCategoriesController < CrudController
  def update_positions
    params["contact_categories_tree"].each do |index,object|
      contact_category = ContactCategory.find_by_id(object["id"])
      contact_category.position = index.to_i + 1
      contact_category.save
    end
    @objects = ContactCategory.find(:all, :order => 'position')
    render :layout => false, :template => "contact_categories/index"
  end
end
