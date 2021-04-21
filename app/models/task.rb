class Task < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :section
  has_many :steps, dependent: :destroy

  validates :title, :contentful_id, presence: true

  def visible_steps
    steps.where(hidden: false)
  end
end
