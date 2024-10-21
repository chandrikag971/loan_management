module Loans
  class Repay
    def initialize(loan:, user:, admin:)
      @loan = loan
      @user = user
      @admin = admin
    end

    attr_reader :loan, :user, :admin

    def call
      total_due = loan.total_due

      if user.wallet >= total_due
        complete_payment(total_due)
      else
        partial_repayment
      end
    end

    private

    def complete_payment(total_due)
      user.wallet -= total_due
      admin.wallet += total_due
      loan.update(status: 'closed', interest_rate: 0)
      admin.save!
      user.save!
      loan.save!
    end

    def partial_payment
      amount_paid = @user.wallet
      user.wallet = 0
      admin.wallet += amount_paid
      loan.update(status: 'closed', interest_rate: 0)
      admin.save!
      user.save!
    end
  end
end
