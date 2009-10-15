class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table "groups", :force => true do |t|
      t.references :user
      t.string     :name
    end

    create_table "group_memberships", :force => true do |t|
      t.references :group
      t.references :user
    end
  end

  def self.down
    drop_table "group_memberships"
    drop_table "groups"
  end
end
