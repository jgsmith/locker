class Upload < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :groups

  def file=(u)
    @file = u
    self.size = u.size
    self.content_type = u.content_type
    self.filename = u.original_filename.gsub(/^.*[\\\/]/,'')
  end

  # TODO: make the following configurable
  def dir_path
    dg = Digest::MD5.hexdigest(self.id.to_s)
    RAILS_ROOT + '/uploads/' + dg[0..1] + '/' + dg[2..3] + '/'
  end

  def can_user_view_upload?(u)
    return true if u == user
    self.groups.each do |group|
      return true if group.is_member?(u)
    end
    return false
  end

  def extension
    if self.filename =~ /(\.[^.]+)$/
      return $1
    else
      return ''
    end
  end

  def path
    self.dir_path + self.id.to_s + self.extension
  end

  def after_save
    FileUtils::mkpath self.dir_path
    FileUtils::cp @file.path, self.path
  end

  def url
    "/files/" + self.id.to_s
  end

  def to_ext_json(options)
    {
      :id => self.id,
      :tags => self.tags.collect{|t| t.name},
      :size => self.size,
      :name => self.public_name,
      :url => self.url
    }.to_ext_json(options)
  end
end
