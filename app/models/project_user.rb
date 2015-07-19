class ProjectUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :user_id, presence: {
    message: "does not exist."
  }
  validates :user_id, uniqueness: { scope: :project_id,
    message: "already joined this project." }
  validates :project_id, presence: true
  validates :priv, length: { minimum: 1, 
      too_short: "shoud not be empty."
   }
  def readable?
    self.priv.downcase.include?("r")
  end

  def writable?
    self.priv.downcase.include?("w")
  end

  def admin?
    self.priv.downcase.include?("a")
  end
end
