module Loans
  class Confirm
    def initialize(loan:, user:, admin:)
      @loan = loan
      @user = user
      @admin = admin
    end

    attr_reader :loan, :user, :admin

    def call
      return unless admin.wallet >= loan.principal

      transfer_funds

      loan.update(status: 'open', amount: loan.principal)
    end

    private

    def transfer_funds
      admin.wallet -= loan.principal
      user.wallet += loan.principal
      admin.save!
      user.save!
    end
  end
end
