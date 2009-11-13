class Account < ActiveRecord::Base
  validates_presence_of :title, :subdomain, :tagline, :on => :create, :message => "can't be blank"
  has_many :appointments
  has_many :agendas, :class_name => "Appointment"
  belongs_to :user
  belongs_to :assistant, :class_name => "User"
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :assistant
  has_attached_file :logo,
    :styles         => { :thumb => "120x160>" },
    :storage        => :s3,
    :s3_credentials => { :access_key_id => ENV["S3_ACCESS_KEY_ID"], :secret_access_key => ENV["S3_SECRET_ACCESS_KEY"] },
    :path           => ":attachment/:id/:style.:extension",
    :bucket         => ENV["S3_BUCKET"]
  after_create :send_assistant_mailer

  def to_s
    self.title
  end

protected
  def send_assistant_mailer
    AccountMailer.deliver_new_assistant(self)
  end
end
