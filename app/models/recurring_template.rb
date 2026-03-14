class RecurringTemplate < ApplicationRecord
  FREQUENCIES = %w[daily weekly biweekly monthly quarterly yearly].freeze

  belongs_to :account
  belongs_to :category
  has_many :transactions, dependent: :nullify

  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :frequency, presence: true, inclusion: { in: FREQUENCIES }
  validates :transaction_type, presence: true, inclusion: { in: Transaction::TYPES }
end
