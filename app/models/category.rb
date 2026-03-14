class Category < ApplicationRecord
  TRANSACTION_TYPES = %w[income expense both].freeze

  # ── Associations ──────────────────────────────────────────────────────────
  belongs_to :user, optional: true  # nil = system/predefined category
  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_id,
           dependent: :destroy, inverse_of: :parent

  # ── Validations ───────────────────────────────────────────────────────────
  validates :name, presence: true
  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }

  # ── Scopes ────────────────────────────────────────────────────────────────
  scope :system,    -> { where(user_id: nil) }
  scope :custom,    -> { where.not(user_id: nil) }
  scope :top_level, -> { where(parent_id: nil) }

  scope :for_income,  -> { where(transaction_type: %w[income both]) }
  scope :for_expense, -> { where(transaction_type: %w[expense both]) }

  # ── Predicates ────────────────────────────────────────────────────────────
  def subcategory? = parent_id.present?
  def system?      = user_id.nil?
end
