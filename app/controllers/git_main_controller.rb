class GitMainController < ApplicationController
  unloadable

  before_filter :require_login, :only => [:index, :new, :create, :update, :upload_key, :create_rep]
  before_filter :require_admin, :only => [:admin, :update_user, :bind, :save_bind]

  def admin
    @git_users = GitUser.find(:all)
  end

  def index
    if GitUser.exists?(User.current.id)
      @git_user = GitUser.find(User.current.id)
      @new_rep = GitRepositories.new
      @user_rep = GitRepositories.all(:conditions => {:owner_id => User.current.id})
    else
      redirect_to :action => 'new'
    end
  end

  def new
    if GitUser.exists?(User.current.id)
      flash[:error] = l(:label_plugin_git_account_already_isset)
      redirect_to :action => 'index', :flash => flash
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
      flash[:warning] = l(:label_plugin_git_not_forget_add_public_key)
      redirect_to :action => 'index', :flash => flash
    else
      render 'new'
    end
  end

  def update
    @git_user = GitUser.find(User.current.id)

    if @git_user.update_attributes(params[:git_user])
      flash[:success] = l(:label_plugin_git_account_update_successful)
      redirect_to :action => 'index', :flash => flash
    else
      flash[:error] = l(:label_plugin_git_account_update_error)
      redirect_to :action => 'index', :flash => flash
    end
  end

  def upload_key
    @git_user = GitUser.find(User.current.id)
    uploaded_key = params[:ssh_public]
    if uploaded_key.nil?
      flash[:error] = l(:label_plugin_git_you_must_select_file)
    else
      if uploaded_key.size < Setting.plugin_chiliproject_git['max_file_ssh_size']
        file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{@git_user.login}"
        if File.exist? file_name
          new_key = GitUsersKey.new
          new_key.user_id = User.current.id
          new_key.file_name = "#{@git_user.login}"
          new_key.save
        end

        File.open("#{file_name}", 'w') do |file|
          file.write(uploaded_key.read)
        end

        @git_user.update_public_key

        flash[:success] = l(:label_plugin_git_public_key_upload)
      else
        flash[:error] = l(:label_plugin_git_big_size_public)
      end
    end
    redirect_to :action => 'index', :flash => flash
  end

  def update_user
    git_user = GitUser.find(params[:id])
    if git_user.blocked == 'T'
      git_user.blocked = 'F'
      #git_user.block git_user
    else
      git_user.blocked = 'T'
      #git_user.unblock git_user
    end

    flash[:success] = l(:label_plugin_git_user_update_success) if git_user.save

    redirect_to :action => 'admin', :flash => flash
  end

  def create_rep
    @git_user = GitUser.find(User.current.id)
    @git_rep = GitRepositories.new(params[:git_repositorie])
    @git_rep.owner_id = User.current.id
    @git_rep.url = "http://git.toiit.sgu.ru/people/#{@git_user.login}/public/#{@git_rep.name}.git"
    if @git_rep.save
      #@git_rep.create_for @git_user, @git_rep.name
      flash[:success] = l(:label_plugin_git_repository_created_successful)
      redirect_to :action => 'index', :flash => flash
    end
  end

  def bind
    if params[:git_id].present?
      @git_user = GitUser.find params[:git_id]
      @users = User.where('id != ?', @git_user.id)
    end
  end

  def save_bind
    if params[:act].present?
      @git_user = GitUser.find params[:git]
      tmp = GitUser.find params[:new_user]
      if params[:act] == 'delete'
        tmp.destroy
        @git_user.id = params[:new_user]
      elsif params[:act] == 'bind'
        id = tmp.id
        tmp.id = @git_user.id
        @git_user.destroy
        @git_user.id = id
        tmp.save
      end
      if @git_user.save
        flash[:success] = 'Привязка успешно сохранена'
      else
        flash[:error] = 'Поменять привязку не получилось'
      end
    end
    redirect_to :action => 'admin', :flash => flash unless flash.nil?
  end
end
