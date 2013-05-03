class CreateGitRepositories < ActiveRecord::Migration
  def self.up
    create_table :git_repositories do |t|
      t.column :name, :string
      t.column :owner_id, :integer
      t.column :url, :string
    end
  end

  def self.down
    drop_table :git_repositories
  end
end
