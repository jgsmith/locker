class CreateUploadFilters < ActiveRecord::Migration
  def self.up
    create_table :upload_filters do |t|
      t.references :user
      t.string :name
      t.string :web_id
      t.integer :size, :default => 10
      t.boolean :require_all
    end

    create_table :groups_upload_filters, :id => false do |t|
      t.references :upload_filter
      t.references :group
    end

    create_table :tags_upload_filters, :id => false do |t|
      t.references :upload_filter
      t.references :tag
    end
  end

  def self.down
    drop_table :groups_upload_filters
    drop_table :tags_upload_filters
    drop_table :upload_filters
  end
end

