class UploadFilter < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :groups

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => 'user_id'
  validates_uniqueness_of :web_id

  def tag_list
    tags.collect {|t| t.name}.join("\n")
  end

  def generate_web_id
    self.web_id = ActiveSupport::SecureRandom.base64(36) 
    # need to handle case where random string is repeated
  end

  def files
    # select all files that match all tags and groups (or any...)
    # based on require_all?

    if self.require_all?
      # require all
      Upload.find(:all,
        :joins => %{
          LEFT JOIN groups_uploads gu ON gu.upload_id = uploads.id
          LEFT JOIN tags_uploads tu ON tu.upload_id = uploads.id
          LEFT JOIN group_memberships gm ON gm.group_id = gu.group_id
          LEFT JOIN groups g ON g.id = gm.group_id
          LEFT JOIN tags_upload_filters ft ON ft.tag_id = tu.tag_id
          LEFT JOIN groups_upload_filters fg ON fg.group_id = gu.group_id
        },
        :select => 'DISTINCT(uploads.*)',
        :order => 'uploads.created_at DESC',
        :limit => self.size,
        :conditions => [ %{
          ft.upload_filter_id = ? AND fg.upload_filter_id = ?
        }, self.id, self.id
        ]
      )
    else
      # require any
      Upload.find(:all,
        :joins => %{
          LEFT JOIN groups_uploads gu ON gu.upload_id = uploads.id
          LEFT JOIN tags_uploads tu ON tu.upload_id = uploads.id
          LEFT JOIN group_memberships gm ON gm.group_id = gu.group_id
          LEFT JOIN groups g ON g.id = gm.group_id
          LEFT JOIN tags_upload_filters ft ON ft.tag_id = tu.tag_id
          LEFT JOIN groups_upload_filters fg ON fg.group_id = gu.group_id
        },
        :select => 'DISTINCT uploads.*',
        :order => 'uploads.created_at DESC',
        :limit => self.size,
        :conditions => [ %{
          ft.upload_filter_id = ? AND fg.upload_filter_id = ?
          AND (gm.user_id = ? OR g.user_id = ?)
        }, 
          self.id, self.id, self.user.id, self.user.id 
        ]
      )
    end
  end
end
