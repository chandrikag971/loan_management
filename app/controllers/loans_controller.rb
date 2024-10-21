class LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan, only: [:approve_without_adjustment, :approve_with_adjustment, :reject, :confirm, :reject_approval, :request_readjustment, :repay]

  def index
    if current_user.admin?
      @loans = Loan.all
    else
      @loans = current_user.loans
    end
  end

  def new
    @loan = current_user.loans.build
  end

  def create
    @loan = current_user.loans.build(loan_params)
    if @loan.save
      redirect_to loans_path, notice: 'Loan request submitted successfully.'
    else
      render :new
    end
  end

  def approve_without_adjustment
    if current_user.admin?
      @loan.update!(status: 'approved')

      # render json: @loan, status: :ok
      redirect_to loans_path, notice: 'Loan approved successfully.'
    else
      render json: {message: 'You are not authorized to perform this action.'}
      redirect_to loans_path, alert: 'You are not authorized to perform this action.'
    end
  end

  def reject
    if current_user.admin? && @loan.requested?
      @loan.update(status: 'rejected')

      redirect_to loans_path, notice: 'Loan request rejected successfully.'
    else
      redirect_to loans_path, alert: 'You are not authorized to reject this loan or the loan is not approved.'
    end
  end

  def approve_with_adjustment
    if current_user.admin?
      @loan.update(amount: params[:amount], interest_rate: params[:interest_rate], status: 'waiting_for_adjustment_acceptance')
      redirect_to loans_path, notice: 'Loan approved with adjustments. Waiting for user acceptance.'
    else
      redirect_to loans_path, alert: 'Invalid amount or interest rate.'
    end
  end

  def confirm
    if @loan.user == current_user && (@loan.approved? || @loan.waiting_for_adjustment_acceptance?)
      # Check if the admin has enough funds
      admin = User.find_by(admin: true) # Adjust according to your admin user setup

      if admin.wallet >= @loan.amount
        # Debit from admin wallet and credit to user's wallet
        admin.wallet -= @loan.amount
        current_user.wallet += @loan.amount

        # Move the loan to the "open" state
        @loan.update(status: 'open')

        admin.save
        current_user.save

        redirect_to loans_path, notice: 'Loan confirmed successfully and funds transferred.'
      else
        redirect_to loans_path, alert: 'Insufficient funds in admin wallet.'
      end
    else
      redirect_to loans_path, alert: 'You are not authorized to confirm this loan or the loan is not approved.'
    end
  end

  def reject_approval
    if @loan.user == current_user && (@loan.approved? || @loan.waiting_for_adjustment_acceptance?)
      @loan.update(status: 'rejected')
      redirect_to loans_path, notice: 'Loan request rejected.'
    else
      redirect_to loans_path, alert: 'You are not authorized to reject this loan.'
    end
  end

  def request_readjustment
    if @loan.status == 'waiting_for_adjustment_acceptance' && @loan.user == current_user
      @loan.update(status: 'readjustment_requested')
      redirect_to loans_path, notice: 'Readjustment requested.'
    else
      redirect_to loans_path, alert: 'You are not authorized to request a readjustment.'
    end
  end

  def repay
    if @loan.user == current_user && @loan.status == 'open'
      total_due = @loan.total_due

      if current_user.wallet >= total_due
        # Deduct from user's wallet and add to admin's wallet
        current_user.wallet -= total_due
        admin = User.find_by(admin: true)
        admin.wallet += total_due

        # Update loan status to closed
        @loan.update(status: 'closed', interest_rate: 0) # Reset interest

        current_user.save
        admin.save
        @loan.save

        redirect_to loans_path, notice: 'Loan repaid successfully.'
      else
        # If insufficient funds, deduct only available amount
        amount_paid = current_user.wallet
        current_user.wallet = 0
        admin.wallet += amount_paid
        @loan.update(status: 'closed', interest_rate: 0) # Close the loan
        current_user.save
        admin.save
        @loan.save

        redirect_to loans_path, notice: 'Loan partially repaid. Loan is now closed.'
      end
    else
      redirect_to loans_path, alert: 'You are not authorized to repay this loan.'
    end
  end


  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end

  def set_loan
    @loan = Loan.find(params[:id])
  end
end
