class CreateGitTables < ActiveRecord::Migration
  def self.up
    create_table :git_tables, :primary_key => :user_id do |t|
      t.column :user_id, :integer
      t.column :git_login, :string
      t.column :git_firstname, :string
      t.column :git_lastname, :string
      t.column :blocked, :string
    end
  end

  def self.down
    drop_table :git_tables
  end
end
