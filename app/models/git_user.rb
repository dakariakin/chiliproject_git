class GitUser < ActiveRecord::Base
  unloadable
  belongs_to :user
end
