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
      @loan.update(status: 'rejected', amount: 0.0)

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
      admin = User.find_by(admin: true)
      Loans::Confirm.new(loan: @loan, user: current_user, admin: admin).call
      redirect_to loans_path, notice: 'Loan confirmed successfully and funds transferred.'
    else
      redirect_to loans_path, alert: 'You are not authorized to confirm this loan or the loan is not approved.'
    end
  rescue => e
    redirect_with_alert(e.message)
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
      admin = User.find_by(admin: true)
      Loans::Repay.new(loan: @loan, user: current_user, admin: admin).call
      redirect_to loans_path, notice: 'Loan repaid successfully.'
    else
      redirect_to loans_path, alert: 'You are not authorized to repay this loan.'
    end
  rescue => e
    redirect_with_alert(e.message)
  end

  private

  def loan_params
    params.require(:loan).permit(:principal, :interest_rate)
  end

  def set_loan
    @loan = Loan.find(params[:id])
  end
end
