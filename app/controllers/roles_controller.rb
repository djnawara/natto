class RolesController < CrudController
  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    if @object.title.eql?('administrator')
      flash[:error] = "The administrator role cannot be deleted."
    else
      Role.transaction do
        id = @object.id
        @object.destroy
        create_change_log_entry(id)
        flash[:notice] = "Role destroyed."
      end
    end
    
    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
end
