class GitMainController < ApplicationController
  unloadable

  before_filter :require_login, :only => [:index, :new, :create, :update]
  before_filter :require_admin, :only => :admin

  def admin
  end

  def index
    if GitUser.exists?(User.current.id)
      @git_user = GitUser.find(User.current.id)
    else
      redirect_to :action => 'new'
    end
  end

  def new
    if GitUser.exists?(User.current.id)
      flash[:error] = l(:label_plugin_git_account_already_isset)
      redirect_to :action => 'index'
    else
      @git_user = GitUser.new
    end
  end

  def create
    @git_user = GitUser.new(params[:git_user])
    @git_user.blocked = 'F'
    @git_user.id = User.current.id
    if @git_user.save
      flash[:success] = l(:label_plugin_git_reg_success)
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end

  def update
    @git_user = GitUser.find(User.current.id)

    if @git_user.update_attributes(params[:git_user])
      flash[:success] = l(:label_plugin_git_account_update_successful)
      redirect_to :action => 'index'
    else
      flash[:error] = l(:label_plugin_git_account_update_error)
      render 'index'
    end
  end
end
