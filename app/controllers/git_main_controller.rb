class GitMainController < ApplicationController
  unloadable

  before_filter :require_login, :only => [:index, :new, :create, :update, :upload_key, :create_rep]
  before_filter :require_admin, :only => [:admin, :update_user]

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
    replace = false
    uploaded_key = params[:ssh_public]
    if uploaded_key.nil?
      flash[:error] = l(:label_plugin_git_you_must_select_file)
    else
      if uploaded_key.size < Setting.plugin_chiliproject_git['max_file_ssh_size']
        file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{@git_user.login}.pub"
        if File.exist? file_name
          replace = true
        end

        File.open("#{file_name}", 'w') do |file|
          file.write(uploaded_key.read)
        end

        unless replace
          new_key = GitUsersKey.new
          new_key.user_id = User.current.id
          new_key.file_name = @git_user.login
          new_key.save
        end

        if replace
          @git_user.delay.update_public_key @git_user
        else
          @git_user.delay.add_to_git @git_user
        end

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
      git_user.delay.block git_user
    else
      git_user.blocked = 'T'
      git_user.delay.unblock git_user
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
      @git_rep.delay.create_for @git_user, @git_rep.name
      flash[:success] = l(:label_plugin_git_repository_created_successful)
      redirect_to :action => 'index', :flash => flash
    end
  end
end
