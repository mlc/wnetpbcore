class UsersController < ApplicationController
  prepend_before_filter :fetch_user
  filter_parameter_logging :password, :password_confirmation

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    @user.is_admin = params[:user][:is_admin] if current_user.is_admin?
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
      if current_user.is_admin? && @user.id != current_user.id
        @user.is_admin = params[:user][:is_admin]
        @user.save
      end
      flash[:message] = "Successfully updated."
      redirect_to(current_user.is_admin? ? {:action => 'index'} : '/')
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

  def authorized?(action = action_name, resource = @user)
    # anonymous users can't do anything
    # normal users can see and edit themselves (only)
    # admins can do anything except delete themselves

    logged_in? &&
      (current_user.is_admin? ||
        (['edit', 'show', 'update'].include?(action) && resource == current_user)) &&
      !(['destroy'].include?(action) && resource == current_user)
  end

end
