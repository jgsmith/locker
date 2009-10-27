class Group < ActiveRecord::Base
  belongs_to :user
  has_many :group_memberships, :dependent => :destroy
  has_and_belongs_to_many :uploads

  validates_uniqueness_of :name, :scope => 'user_id'
  validates_presence_of   :name
  validates_length_of     :name, :within => 3..200

  def is_member?(u)
    return false if u.nil?
    !GroupMembership.first(
      :conditions => [
        'group_id = ? AND user_id = ?',
         self.id, u.id
      ]).nil?
  end

  def members
    group_memberships.collect {|m| m.user.login}.join("\n")
  end

  def name_for(u)
    if u == user
      self.name
    else
      self.name + ' (' + self.user.login + ')'
    end
  end
end
