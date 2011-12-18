class AssetDateTypesController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore = %w(availableEnd availableStart broadcast 
      content created issued portrayed published revised).to_set.freeze
  end
  
  def index
    respond_to do |format|
      format.html { super }
      format.json do 
        render :json => @klass.find(:all, :conditions => ["name like ? and visible = 1", "%#{params[:term]}%"],
                                          :order => "name ASC").map(&:name)
      end
    end
  end
end
