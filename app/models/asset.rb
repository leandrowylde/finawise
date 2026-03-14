class Asset < ApplicationRecord
  TYPES = %w[house car other].freeze

  belongs_to :user
  has_many :transactions, dependent: :nullify

  validates :name, presence: true
  validates :asset_type, presence: true, inclusion: { in: TYPES }
end
