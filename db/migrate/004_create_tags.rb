class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
    end

    create_table :tags_uploads, :id => false do |t|
      t.references :upload
      t.references :tag
    end
  end

  def self.down
    drop_table :tags_uploads
    drop_table :tags
  end
end
