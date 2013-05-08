class MoveDataFromGittois < ActiveRecord::Migration
  def self.up
    old = Gittoi.all
    old.each do |current|
      if GitUser.exists?(current.user_id) or GitUser.exists?(:login => current.git_login)
        puts "WARNING!! User #{current.git_login} not be moved, already exists"
      else
        new = GitUser.new
        new.id = current.user_id
        new.login = current.git_login
        new.firstname = current.git_fname
        new.lastname = current.git_sname
        new.blocked = current.git_status = 1 ? 'T' : 'F'
        current.destroy if new.save
        puts "Move user #{new.login}"
      end
    end
  end
end
