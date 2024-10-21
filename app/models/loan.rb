class Loan < ApplicationRecord
  belongs_to :user

  STATUSES = %w[requested approved open closed rejected waiting_for_adjustment_acceptance readjustment_requested].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :amount, :interest_rate, presence: true

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
    minutes_open = ((Time.current - updated_at) / 60).to_i

    # interest_rate is assumed to be on per annum basis
    total_interest = (amount * interest_rate) * (minutes_open / 525600.0)
    (amount + total_interest).round(2)  # Round to 2 decimal places
  end
end
