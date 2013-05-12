class GitUser < ActiveRecord::Base
  unloadable
  belongs_to :user
  has_one :user, :foreign_key => 'id'
  validates_length_of :login, :in => 2..100, :message => l(:label_plugin_git_login_length_error)
  validates_uniqueness_of :login, :id, :message => l(:label_plugin_git_login_already_isset)

  def make(file)
    unless @command.nil? and file.nil?
      path = "#{Setting.plugin_chiliproject_git['dir_git_actions']}/#{self.login}.pub"
      FileUtils.copy_file(file, path)

      i = 0
      while i < Setting.plugin_chiliproject_git['time_for_wait'].to_i
        if File.exists? path
          sleep (1.seconds)
          i += 1
        else
          break
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

  def update_public_key
    file_name = "#{Setting.plugin_chiliproject_git['dir_ssh_public']}/#{self.login}.pub"
    self.make file_name
  end
end
