class Plan < ApplicationRecord
  has_many :users, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:points) }

  def self.default_plan
    find_by(name: 'Free Plan') || active.ordered.first
  end

  def self.find_by_name(name)
    find_by(name: name)
  end

  def to_s
    name
  end

  def can_upgrade_to?(other_plan)
    other_plan.points > points
  end

  def can_downgrade_to?(other_plan)
    other_plan.points < points
  end
end
