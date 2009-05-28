# == Schema Information
# Schema version: 20090528153509
#
# Table name: users
#
#  id                        :integer(4)    not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  activation_code           :string(40)    
#  activated_at              :datetime      
#  state                     :string(255)   default("passive")
#  deleted_at                :datetime      
#  admin                     :boolean(1)    
#  reset_password_code       :string(255)   
#  reset_password_sent_at    :datetime      
#  score                     :integer(4)    default(0)
#  logged_in_at              :datetime      
#

require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :podcasts, :foreign_key => 'finder_id', :uniq => true
  has_many :owned_podcasts, :class_name => 'Podcast', :foreign_key => 'owner_id'
  has_many :reviews, :dependent => :destroy
  has_many :review_ratings, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :favorite_podcasts, :through => :favorites, :source => :podcast
  has_many :user_taggings, :dependent => :destroy
  has_many :taggings, :through => :user_taggings, :include => :tag, :order => 'tags.name ASC'

  attr_accessor :password # Virtual attribute for the unencrypted password
  attr_accessor_with_default :messages, []

  validates_presence_of     :login
  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i
  validates_format_of       :login, :with => /^[A-Za-z0-9\-\_\.]+$/
  before_save :encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :state

  named_scope :older_than, lambda {|date| {:conditions => ["users.created_at < (?)", date]} }
  named_scope :frequent_users, {:conditions => ["users.logged_in_at > (?)", 29.days.ago]}
  named_scope :admins, {:conditions => {:admin => true}}
  named_scope :nonadmins, {:conditions => "admin IS NULL OR admin IS FALSE"}
  named_scope :nonpassive, { :conditions => "users.state IS NULL OR users.state != 'passive'" }
  named_scope :makers, { :select => "users.*, count(podcasts.id) as podcast_count", :joins => :owned_podcasts, :group => "users.id", :having => "podcast_count > 0" }

  # States
  %w(passive unconfirmed confirmed).each do |meth|
    named_scope meth.to_sym, {:conditions => {:state => meth}}
    define_method("#{meth}?") { state == meth.to_s }
  end


  define_index do
    indexes :login, :email
  end


  # Authenticates a user by their login name or email and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = if login =~ /@/
      self.find_by_email(login)
    else
      self.find_by_login(login)
    end
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.find_or_create_by_email(email)
    user = find_or_initialize_by_email(email)
    user.save if user.new_record?

    return user
  end

  def self.find_or_initialize_by_email(email)
    if user = User.find_by_email(email)
      # Do nothing
    else
      login = email.blank? ? "user" : email.to_s.gsub(/[^A-Za-z0-9\s]/, "")[0..39]

      login = "#{login} 2" if User.exists?(:login => login)
      login.increment! while User.exists?(:login => login)

      user = User.new(:state => 'passive', :email => email, :login => login)
      user.generate_reset_password_code
    end

    return user
  end

  # Returns the first 6 bytes from a salted hexdigest (the full string is unnecessary)
  def self.generate_code(salt)
    Digest::MD5.hexdigest("CODE FOR #{salt} at #{Time.now}")[0..5]
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def admin?
    self.admin
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def calculate_score!
    update_attribute :score, (podcasts(true).size + reviews(true).size)
  end

  def new?
    created_at == updated_at
  end

  def rank(options={})
    if options[:include_admin] && admin?
      "admin"
    elsif podcaster?
      "podcaster"
    else
      "regular"
    end
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  # Make sure the state is a string; symbols get serialized in the db
  def state=(val)
    write_attribute(:state, val.to_s)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def generate_reset_password_code
    unless attributes["reset_password_code"]
      self.reset_password_code = User.generate_code("reset_password_code for #{email}")
      self.reset_password_sent_at = Time.now
      self.reset_password_code
    end
  end

  # Returns true if the user has just been activated.
  def recently_confirmed?
    @confirmed
  end

  def to_param
    self.login
  end

  def podcaster?
    self.owned_podcasts.count > 0
  end

  def unconfirm
    self.state           = "unconfirmed"
    self.deleted_at      = nil
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def confirm
    @confirmed           = true
    self.activated_at    = Time.now.utc
    self.deleted_at      = nil
    self.activation_code = nil
    self.state           = 'confirmed'
  end

  # This user has only been saved once.
  def fresh?
    created_at == updated_at
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      (crypted_password.blank? || !password.blank?) && state != 'passive'
    end
end
