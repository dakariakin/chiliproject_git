class GitRepositories < ActiveRecord::Base
  unloadable
  belongs_to :git_user

  def make
    unless @command.nil?
      system @command
    end
  end

  def create_for (user)
    @command = "girar-init-db: /people/#{user.login}/packages/#{self.name}.git"
    self.make
  end

  handle_asynchronously :create_for, :run_at => Proc.new { 2.second.from_now }
end
