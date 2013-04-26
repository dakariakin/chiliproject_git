class CreateGitUsersKeys < ActiveRecord::Migration
  def self.up
    create_table :git_users_keys do |t|
      t.column :id, :integer
      t.column :user_id, :integer
      t.column :file_name, :string
    end
  end

  def self.down
    drop_table :git_users_keys
  end
end
