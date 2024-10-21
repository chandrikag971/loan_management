class CalculateLoanInterestJob < ApplicationJob
  queue_as :default

  def perform
    Loan.where(status: 'open').find_each do |loan|
      loan.update(total_due: loan.total_due)
    end
  end
end
