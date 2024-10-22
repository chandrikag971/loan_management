class Loan < ApplicationRecord
  belongs_to :user

  STATUSES = %w[requested approved open closed rejected waiting_for_adjustment_acceptance readjustment_requested].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :principal, :interest_rate, presence: true

  def requested?
    status == 'requested'
  end

  def approved?
    status == 'approved'
  end

  def waiting_for_adjustment_acceptance?
    status == 'waiting_for_adjustment_acceptance'
  end

  def total_due
      interest = principal * interest_rate * (5.0 / (60 * 24))

      self.amount = (amount + interest).round(2)
      self.save
  end
end
