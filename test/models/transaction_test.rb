require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  # ─── Fixtures ───────────────────────────────────────────────────────────────

  def setup
    @account  = accounts(:checking)
    @category = categories(:food)
    @transaction = Transaction.new(
      account:          @account,
      category:         @category,
      date:             Date.current,
      amount:           50.00,
      currency:         "USD",
      description:      "Coffee",
      transaction_type: "expense",
      status:           "paid"
    )
  end

  # ─── Valid record ────────────────────────────────────────────────────────────

  test "valid with all required attributes" do
    assert @transaction.valid?
  end

  test "fixtures are valid" do
    assert transactions(:grocery_expense).valid?
    assert transactions(:salary_income).valid?
    assert transactions(:pending_bill).valid?
  end

  # ─── Associations ────────────────────────────────────────────────────────────

  test "belongs to account" do
    assert_respond_to @transaction, :account
    assert_equal @account, @transaction.account
  end

  test "belongs to category" do
    assert_respond_to @transaction, :category
    assert_equal @category, @transaction.category
  end

  test "asset is optional" do
    @transaction.asset = nil
    assert @transaction.valid?
  end

  test "recurring_template is optional" do
    @transaction.recurring_template = nil
    assert @transaction.valid?
  end

  # ─── Presence validations ────────────────────────────────────────────────────

  test "requires account" do
    @transaction.account = nil
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:account], "must exist"
  end

  test "requires category" do
    @transaction.category = nil
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:category], "must exist"
  end

  test "requires date" do
    @transaction.date = nil
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:date], "can't be blank"
  end

  test "requires amount" do
    @transaction.amount = nil
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:amount], "can't be blank"
  end

  test "requires currency" do
    @transaction.currency = nil
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:currency], "can't be blank"
  end

  test "requires description" do
    @transaction.description = nil
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:description], "can't be blank"
  end

  # ─── Amount validations ──────────────────────────────────────────────────────

  test "amount must be greater than zero" do
    @transaction.amount = 0
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:amount], "must be greater than 0"
  end

  test "amount must not be negative" do
    @transaction.amount = -10
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:amount], "must be greater than 0"
  end

  test "amount can be a decimal" do
    @transaction.amount = 19.99
    assert @transaction.valid?
  end

  # ─── transaction_type enum ───────────────────────────────────────────────────

  test "valid transaction types" do
    %w[income expense transfer].each do |type|
      @transaction.transaction_type = type
      assert @transaction.valid?, "Expected #{type} to be valid"
    end
  end

  test "rejects invalid transaction_type" do
    @transaction.transaction_type = "gift"
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:transaction_type], "is not included in the list"
  end

  test "requires transaction_type" do
    @transaction.transaction_type = nil
    assert_not @transaction.valid?
  end

  # ─── status enum ─────────────────────────────────────────────────────────────

  test "valid statuses" do
    %w[pending paid scheduled].each do |status|
      @transaction.status = status
      assert @transaction.valid?, "Expected #{status} to be valid"
    end
  end

  test "rejects invalid status" do
    @transaction.status = "cancelled"
    assert_not @transaction.valid?
    assert_includes @transaction.errors[:status], "is not included in the list"
  end

  test "requires status" do
    @transaction.status = nil
    assert_not @transaction.valid?
  end

  # ─── Scopes ──────────────────────────────────────────────────────────────────

  test "income scope returns only income transactions" do
    income = Transaction.income
    assert income.all? { |t| t.transaction_type == "income" }
    assert_includes income, transactions(:salary_income)
    assert_not_includes income, transactions(:grocery_expense)
  end

  test "expenses scope returns only expense transactions" do
    expenses = Transaction.expenses
    assert expenses.all? { |t| t.transaction_type == "expense" }
    assert_includes expenses, transactions(:grocery_expense)
    assert_not_includes expenses, transactions(:salary_income)
  end

  test "pending scope returns only pending transactions" do
    pending_txns = Transaction.pending
    assert pending_txns.all? { |t| t.status == "pending" }
    assert_includes pending_txns, transactions(:pending_bill)
    assert_not_includes pending_txns, transactions(:salary_income)
  end

  test "for_month scope filters by year and month" do
    march = Transaction.for_month(2026, 3)
    assert_includes march, transactions(:grocery_expense)
    assert_includes march, transactions(:salary_income)
  end

  # ─── Helper methods ──────────────────────────────────────────────────────────

  test "income? returns true for income transactions" do
    assert transactions(:salary_income).income?
  end

  test "expense? returns true for expense transactions" do
    assert transactions(:grocery_expense).expense?
  end

  test "transfer? returns true for transfer transactions" do
    @transaction.transaction_type = "transfer"
    @transaction.save!
    assert @transaction.transfer?
  end

  test "paid? returns true when status is paid" do
    assert transactions(:salary_income).paid?
  end

  test "pending? returns true when status is pending" do
    assert transactions(:pending_bill).pending?
  end
end
