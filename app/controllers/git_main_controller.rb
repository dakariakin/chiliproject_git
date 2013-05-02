class GitMainController < ApplicationController
  unloadable

  before_filter :require_login, :only => [:index, :new, :create, :update, :upload_key]
  before_filter :require_admin, :only => [:admin, :update_user]

  def admin
    @git_users = GitUser.find(:all)
  end

  def index
    if GitUser.exists?(User.current.id)
      @git_user = GitUser.find(User.current.id)
      @user_keys = GitUsersKey.all(:conditions => {:user_id => User.current.id})
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
      Dir.mkdir "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{@git_user.login}"
      flash[:success] = l(:label_plugin_git_reg_success)
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
      original_filename = uploaded_key.original_filename
      if uploaded_key.size < Setting.plugin_chiliproject_git['max_file_ssh_size']
        file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{@git_user.login}/#{uploaded_key.original_filename}"
        if File.exist? file_name
          i = 0
          while File.exists? "#{file_name}#{i}"
            i+=1
          end
          file_name += i.to_s
          original_filename += i.to_s
        end

        File.open("#{file_name}", 'w') do |file|
          file.write(uploaded_key.read)
        end

        new_key = GitUsersKey.new
        new_key.user_id = User.current.id
        new_key.file_name = original_filename
        new_key.save

        flash[:success] = l(:label_plugin_git_public_key_upload)
        @user_keys = GitUsersKey.all(:conditions => {:user_id => User.current.id})
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
    else
      git_user.blocked = 'T'
    end

    flash[:success] = l(:label_plugin_git_user_update_success) if git_user.save

    redirect_to :action => 'admin', :flash => flash
  end
end
