class GitMainController < ApplicationController
  unloadable


  def admin
  end

  def index
    if GitTable.exists?(User.current.id)
      @user = GitTable.find(User.current.id)
    else
      redirect_to :action => 'new'
    end
  end

  def new
    @git_user = GitTable.new
  end

  def create
    @git_user = GitTable.new(params[:git_user])
    if @git_user.save
      flash[:success] = l(:label_plugin_git_reg_success)
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end
end
