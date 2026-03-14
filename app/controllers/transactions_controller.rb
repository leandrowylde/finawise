class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy]
  helper_method :current_user_accounts, :current_user_categories

  def index
    @transactions = current_user_transactions.recent
  end

  def show
  end

  def new
    @transaction = Transaction.new(currency: default_currency, status: "paid", date: Date.current)
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      redirect_to @transaction, notice: "Transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: "Transaction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy!
    redirect_to transactions_url, notice: "Transaction was successfully deleted."
  end

  private

    def set_transaction
      @transaction = current_user_transactions.find(params[:id])
    end

    def current_user_transactions
      Transaction.joins(:account).where(accounts: { user: Current.user })
    end

    def current_user_accounts
      Current.user.accounts.order(:name)
    end

    def current_user_categories
      Category.where(user: Current.user).or(Category.system).order(:name)
    end

    def default_currency
      Current.user.accounts.first&.currency || "USD"
    end

    def transaction_params
      params.require(:transaction).permit(
        :account_id, :category_id, :asset_id, :recurring_template_id,
        :date, :amount, :currency, :description, :notes,
        :transaction_type, :status, :exchange_rate
      )
    end
end
