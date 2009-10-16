class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.references :user
      t.string :display_name
      t.string :filename
      t.integer :size
      t.string :content_type
      t.text    :description

      t.timestamps
    end

    create_table "groups_uploads", :force => true, :id => false do |t|
      t.references :group
      t.references :upload
    end
  end

  def self.down
    drop_table :groups_uploads
    drop_table :uploads
  end
end
