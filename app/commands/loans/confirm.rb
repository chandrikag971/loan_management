module Loans
  class Confirm
    def initialize(loan:, user:, admin:)
      @loan = loan
      @user = user
      @admin = admin
    end

    attr_reader :loan, :user, :admin

    def call
      byebug
      return unless admin.wallet >= loan.amount

      transfer_funds

      loan.update(status: 'open')
    end

    private

    def transfer_funds
      admin.wallet -= loan.amount
      user.wallet += loan.amount
      admin.save!
      user.save!
    end
  end
end
