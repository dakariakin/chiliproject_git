class GitUser < ActiveRecord::Base
  unloadable
  belongs_to :user
  validates_length_of :login, :in => 2..100, :message => l(:label_plugin_git_login_length_error)
  validates_uniqueness_of :login, :id, :message => l(:label_plugin_git_login_already_isset)

  def make
    unless @command.nil?
      system @command
    end
  end

  handle_asynchronously :make, :run_at => Proc.new { 1.second.from_now }

  def block_user(user)
    @command = "girar-disable #{user.login}"
    self.make
  end

  def unblock_user(user)
    @command = "girar-enable #{user.login}"
    self.make
  end

  def add_user(user, key)
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{user.login}/#{key}"
    @command = "girar-add #{user.login} #{file_name} #{user.firstname} #{user.lastname}"
    self.make
  end

  def update_public_key(user, key)
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{user.login}/#{key}"
    @command = "girar-auth-add #{user.login} #{file_name}"
    self.make
  end
end
