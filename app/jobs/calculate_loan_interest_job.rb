class CalculateLoanInterestJob < ApplicationJob
  queue_as :default

  def perform
    Loan.where(status: 'open').find_each do |loan|
      loan.update!(amount: loan.total_due_amount)
    end
  end
end
