class GitUser < ActiveRecord::Base
  unloadable
  belongs_to :user
  validates_length_of :login, :in => 2..100, :message => l(:label_plugin_git_login_length_error)
  validates_uniqueness_of :login, :id, :message => l(:label_plugin_git_login_already_isset)

  def make(file)
    unless @command.nil? and file.nil?
      file_name = Time.new.to_time.to_i.to_s.concat("_#{file}")
      path = "#{Setting.plugin_chiliproject_git['dir_git_actions']}/#{file_name}"
      File.open(path, 'w') do |file|
        file.write(@command)
      end

      i = 0
      while i < Setting.plugin_chiliproject_git['time_for_wait'].to_i
        if File.exists? path
          break
        else
          sleep 1.second
          i += 1
        end
      end
    end
  end

  def block(git_user)
    @command = "girar-disable #{git_user.login}"
    self.make 'block'
  end

  def unblock(git_user)
    @command = "girar-enable #{git_user.login}"
    self.make 'unblock'
  end

  def add_to_git(git_user)
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{git_user.login}.pub"
    @command = "girar-add #{git_user.login} #{file_name} #{git_user.firstname} #{git_user.lastname}"
    self.make 'add'
  end

  def update_public_key(git_user)
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{git_user.login}.pub"
    @command = "girar-auth-add #{git_user.login} #{file_name}"
    self.make 'update_key'
  end

  handle_asynchronously :block, :run_at => Proc.new { 1.second.from_now }
  handle_asynchronously :unblock, :run_at => Proc.new { 1.second.from_now }
  handle_asynchronously :add_to_git, :run_at => Proc.new { 1.second.from_now }
  handle_asynchronously :update_public_key, :run_at => Proc.new { 1.second.from_now }
end
