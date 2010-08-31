class UsersController < ApplicationController
  prepend_before_filter :fetch_user
  filter_access_to :all

  filter_parameter_logging :password, :password_confirmation

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    if permitted_to?(:make_admin, @user)
      @user.role = params[:user][:role]
      @user.ip_block_id = params[:user][:ip_block_id]
    end

    success = @user && @user.save
    if success && @user.errors.empty?
      flash[:message] = "#{@user.login} created"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def show
    edit
  end

  def edit
    render :action => 'edit'
  end

  def update
    if @user.update_attributes(params[:user])
      permitted_to?(:make_admin, @user) do
        @user.role = params[:user][:role]
        @user.ip_block_id = params[:user][:ip_block_id]
        @user.save
      end
      flash[:message] = "Successfully updated."
      redirect_to(permitted_to?(:index, :users) ? {:action => 'index'} : '/')
    else
      render :action => 'edit'
    end
  end

  def index
    @users = User.find(:all, :order => :login)
  end

  def destroy
    username = @user.login
    @destroyed_id = @user.id
    @user.destroy
    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{username}</strong> has been deleted."
        redirect_to :action => "index"
      end
      format.js
    end
  end

  protected
  def fetch_user
    @user = User.find(params[:id]) if params[:id]
  end
end
