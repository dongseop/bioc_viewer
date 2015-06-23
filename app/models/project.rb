class Project < ActiveRecord::Base
  belongs_to :owner, class_name: "User", foreign_key: 'user_id'
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  has_many :documents, dependent: :destroy
  
  validates :title, presence: true
  validates :user_id, presence: true

  after_create :add_owner_to_users

  def add_owner_to_users
    self.project_users.create({user_id: self.user_id, priv: "rwa"})
  end

  def owner?(user)
    self.owner.id == user.id
  end

  def readable?(user)
    pu = self.project_users.where("user_id = ?", user.id).first
    !pu.nil? && pu.priv.downcase.include?("r")
  end

  def writable?(user)
    pu = self.project_users.where("user_id = ?", user.id).first
    !pu.nil? && pu.priv.downcase.include?("w")
  end

  def admin?(user)
    pu = self.project_users.where("user_id = ?", user.id).first
    !pu.nil? && pu.priv.downcase.include?("a")
  end
end
