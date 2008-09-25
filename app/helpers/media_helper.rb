module MediaHelper
  def get_medium_indices(collection)
    if params[:medium].blank?
      current_medium  = collection.first
      previous_medium = (@object.media.size > 0 ? @object.media.size - 1 : 0)
      next_medium     = (@object.media.size > 1 ? 1 : 0)
    else
      current_medium  = collection[params[:medium].to_i]
      previous_medium = (params[:medium].to_i == 0 ? (@object.media.size - 1) : params[:medium].to_i - 1)
      next_medium     = (params[:medium].to_i >= (@object.media.size - 1) ? 0 : params[:medium].to_i + 1)
    end
    return current_medium, previous_medium, next_medium
  end
end