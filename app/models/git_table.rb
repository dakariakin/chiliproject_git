class GitTable < ActiveRecord::Base
  unloadable
  self.primary_key = 'user_id'
end
