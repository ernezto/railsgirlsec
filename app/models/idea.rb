class Idea < ActiveRecord::Base
  mount_uploader :picture, PictureUploader
  belongs_to :user
  acts_as_commontable
  acts_as_votable
end
