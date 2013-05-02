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

  def block
    @command = "girar-disable #{self.login}"
    self.make
  end

  def unblock
    @command = "girar-enable #{self.login}"
    self.make
  end

  def add_to_git(key)
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{user.login}/#{key}"
    @command = "girar-add #{self.login} #{file_name} #{self.firstname} #{self.lastname}"
    self.make
  end

  def update_public_key(key)
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{user.login}/#{key}"
    @command = "girar-auth-add #{self.login} #{file_name}"
    self.make
  end

  handle_asynchronously :block, :run_at => Proc.new { 2.second.from_now }
  handle_asynchronously :unblock, :run_at => Proc.new { 2.second.from_now }
  handle_asynchronously :add_to_git, :run_at => Proc.new { 2.second.from_now }
  handle_asynchronously :update_public_key, :run_at => Proc.new { 2.second.from_now }
end
