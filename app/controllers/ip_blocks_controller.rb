class IpBlocksController < ApplicationController
  filter_access_to :all
  before_filter :fetch_block

  def index
    @blocks = IpBlock.find(:all, :order => :name)
  end

  def new
    @ip_block = IpBlock.new
  end

  def create
    @ip_block = IpBlock.new
    @ip_block.name = params[:ip_block][:name]
    @ip_block.set_ranges(params[:ipranges], params[:netmasks])
    if @ip_block.save
      flash[:message] = "#{@ip_block.name} created"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    render :action => 'edit'
  end

  def update
    @ip_block.name = params[:ip_block][:name]
    @ip_block.set_ranges(params[:ipranges], params[:netmasks])
    if @ip_block.save
      flash[:message] = "#{@ip_block.name} modified"
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @ip_block.users.empty?
      @destroyed_id = @ip_block.id
      @ip_block.destroy
    end
  end

  protected
  def fetch_block
    @ip_block = IpBlock.find(params[:id]) if params[:id]
  end
end
