class CreateGitUsers < ActiveRecord::Migration
  def self.up
    create_table :git_users do |t|
      t.column :id, :integer
      t.column :login, :string
      t.column :firstname, :string
      t.column :lastname, :string
      t.column :blocked, :string
    end
  end

  def self.down
    drop_table :git_users
  end
end
