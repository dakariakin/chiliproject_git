class GitUser < ActiveRecord::Base
  unloadable
  belongs_to :user
  validates_length_of :login, :in => 2..100, :message => l(:label_plugin_git_login_length_error)
  validates_uniqueness_of :login, :message => l(:label_plugin_git_login_already_isset)
end
