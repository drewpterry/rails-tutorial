class Micropost < ActiveRecord::Base
  belongs_to :user #foreign key
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader #tells Carrier wave to associate the image with this model
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size #this is a custom validation

  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB") #adds to error collection
      end
    end
end
