class GitUsersKey < ActiveRecord::Base
  unloadable
  belongs_to :git_user
end
