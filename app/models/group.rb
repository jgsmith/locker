class Group < ActiveRecord::Base
  belongs_to :user
  has_many :group_memberships
  has_and_belongs_to_many :uploads

  def is_member?(u)
    !self.group_memberships.find(:conditions => ['user_id = ?', u.id]).empty?
  end

  def name_for(u)
    if u == user
      self.name
    else
      self.name + '@' + self.user.login
    end
  end
end
