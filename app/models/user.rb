class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, presence: true
  validates :name, presence: true

  has_many :owner_projects, class_name: "Project", foreign_key: 'user_id'
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
end
