class Category < ApplicationRecord
  TYPES = %w[income expense both].freeze

  belongs_to :user, optional: true
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
  has_many :transactions, dependent: :nullify

  validates :name, presence: true
  validates :transaction_type, presence: true, inclusion: { in: TYPES }

  scope :system, -> { where(user_id: nil) }
  scope :custom, -> { where.not(user_id: nil) }
  scope :top_level, -> { where(parent_id: nil) }
end
