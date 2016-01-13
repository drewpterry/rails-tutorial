class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy #if user is destroyed all posts are also destroyed
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed #rails assumes it is followeds, so we change it to following
  has_many :followers, through: :passive_relationships, source: :follower #don't source follower because it will automatically truncate followers into follower...but I like it this way better

  attr_accessor :remember_token, :activation_token , :reset_token#visible to outside of object, can read and write
  before_save :downcase_email
  #self.email.downcase is optional
  # before_save { email.downcase! } #mutates the actual string
  before_create :create_activation_digest
  # before_save { self.email = self.email.downcase }
    #remember parenthesis are optional
  validates(:name, presence: true, length: { maximum: 50 })
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    #automatically assumes uniqueness
                    uniqueness: { case_sensitive: false }
                    
  has_secure_password # this separately checks if password is secured including password is nil, so validates allowing nil still works - i dont know why
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  #returns hash digest of given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
    #returns a random token
  def User.new_token #do you have to have User part why can't you just use new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    #remember digest is a column in the user field
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") #send lets you call on functions dynamically by calling a string
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

    # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  def feed
    Micropost.where("user_id = ?", id) #putting the question mark escapes characters (avoiding sql injections)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

# return users feed
  def feed
    following_ids = "SELECT followed_id FROM relationships
                    WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                    OR user_id = :user_id", user_id: id)
  end

    private
      def create_activation_digest
        self.activation_token  = User.new_token
        self.activation_digest = User.digest(activation_token)
      end
      
      def downcase_email
        self.email = email.downcase
      end
end

# presence true means not blank or nil