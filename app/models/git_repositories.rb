class GitRepositories < ActiveRecord::Base
  unloadable
  belongs_to :git_user

  def make
    unless @command.nil?
      system @command
    end
  end

  def create_for (git_user, name)
    @command = "girar-init-db: /people/#{git_user.login}/packages/#{name}.git"
    self.make
  end

  handle_asynchronously :create_for, :run_at => Proc.new { 1.second.from_now }
end
