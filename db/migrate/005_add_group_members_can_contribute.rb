class AddGroupMembersCanContribute < ActiveRecord::Migration
  def self.up
    add_column :groups, :members_can_contribute, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :members_can_contribute
  end
end
