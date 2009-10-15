class Tag < ActiveRecord::Base
  has_and_belongs_to_many :uploads

  validates_uniqueness_of :name
end
