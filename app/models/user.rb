class User < ActiveRecord::Base
  #self.email.downcase is optional
  before_save { email.downcase! } #mutates the actual string
  # before_save { self.email = self.email.downcase }
    #remember parenthesis are optional
  validates(:name, presence: true, length: { maximum: 50 })
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    #automatically assumes uniqueness
                    uniqueness: { case_sensitive: false }
                    
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end

# presence true means not blank or nil