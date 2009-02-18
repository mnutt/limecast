# == Schema Information
# Schema version: 20090201232032
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
  has_many :feeds, :foreign_key => 'finder_id', :conditions => {:state => 'parsed'}
  has_many :podcasts, :through => :feeds, :uniq => true
  has_many :owned_podcasts, :class_name => 'Podcast', :foreign_key => 'owner_id', :dependent => :destroy
  has_many :reviews, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :favorite_podcasts, :through => :favorites, :source => :podcast
  has_many :user_taggings, :dependent => :destroy
  has_many :taggings, :through => :user_taggings

  attr_accessor :password # Virtual attribute for the unencrypted password
  attr_accessor_with_default :messages, []

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email, :with => %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i
  validates_format_of       :login, :with => /^[A-Za-z0-9\-\_\.]+$/
  before_save :encrypt_password
  
  before_update :reconfirm_email?

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password

  acts_as_state_machine :initial => :passive
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end

  event :change_email do
    transitions :from => [:pending, :active, :passive], :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end

  event :activate do
    transitions :from => :pending, :to => :active
  end

  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end

  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  named_scope :older_than, lambda {|date| {:conditions => ["users.created_at < (?)", date]} }
  named_scope :active,  {:conditions => {:state => 'active'}}
  named_scope :frequent_users, {:conditions => ["users.logged_in_at > (?)", 29.days.ago]}

  define_index do
    indexes :login, :email

    has :created_at
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

  def self.generate_code(salt)
    Digest::MD5.hexdigest("CODE FOR #{salt} at #{Time.now}")
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
  def recently_activated?
    @activated
  end

  def to_param
    self.login
  end

  def podcaster?
    self.owned_podcasts.count > 0
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_activation_code
      self.deleted_at = nil
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      @activated = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end

    def reconfirm_email?
      if active? && email_changed?
        change_email!
        UserMailer.deliver_signup_notification(self)
      end
    end
end
