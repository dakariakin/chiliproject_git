class GitMainController < ApplicationController
  unloadable


  def admin
  end

  def index
    if GitUser.exists?(User.current.id)
      @user = GitUser.find(User.current.id)
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
end
