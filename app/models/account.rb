class Account < ApplicationRecord
  TYPES = %w[checking savings credit_card cash investment].freeze

  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :name, presence: true
  validates :account_type, presence: true, inclusion: { in: TYPES }
  validates :currency, presence: true
  validates :balance, presence: true, numericality: true
end
