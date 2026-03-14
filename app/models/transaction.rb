class Transaction < ApplicationRecord
  TYPES    = %w[income expense transfer].freeze
  STATUSES = %w[pending paid scheduled].freeze

  belongs_to :account
  belongs_to :category
  belongs_to :asset, optional: true
  belongs_to :recurring_template, optional: true

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :description, presence: true
  validates :transaction_type, presence: true, inclusion: { in: TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :income,    -> { where(transaction_type: "income") }
  scope :expenses,  -> { where(transaction_type: "expense") }
  scope :transfers, -> { where(transaction_type: "transfer") }
  scope :pending,   -> { where(status: "pending") }
  scope :paid,      -> { where(status: "paid") }
  scope :scheduled, -> { where(status: "scheduled") }
  scope :for_month, ->(year, month) { where(date: Date.new(year, month).all_month) }
  scope :recent,    -> { order(date: :desc, created_at: :desc) }

  def income?    = transaction_type == "income"
  def expense?   = transaction_type == "expense"
  def transfer?  = transaction_type == "transfer"
  def paid?      = status == "paid"
  def pending?   = status == "pending"
  def scheduled? = status == "scheduled"
end
