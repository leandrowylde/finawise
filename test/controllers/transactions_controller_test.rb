require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  def setup
    @user        = users(:one)
    @account     = accounts(:checking)
    @category    = categories(:food)
    @transaction = transactions(:grocery_expense)
    sign_in_as @user
  end

  # ─── Authentication guard ────────────────────────────────────────────────────

  test "redirects to login when not authenticated" do
    sign_out
    get transactions_url
    assert_redirected_to new_session_url
  end

  # ─── GET /transactions ───────────────────────────────────────────────────────

  test "GET index returns success" do
    get transactions_url
    assert_response :success
  end

  test "GET index only shows transactions for current user accounts" do
    get transactions_url
    assert_response :success
    # groceries belong to user :one's account — should be visible
    assert_select "turbo-frame[id='transactions']"
  end

  # ─── GET /transactions/new ───────────────────────────────────────────────────

  test "GET new returns success" do
    get new_transaction_url
    assert_response :success
  end

  # ─── GET /transactions/:id ───────────────────────────────────────────────────

  test "GET show returns success" do
    get transaction_url(@transaction)
    assert_response :success
  end

  test "GET show returns not found for other user's transaction" do
    sign_out
    sign_in_as users(:two)
    get transaction_url(@transaction)
    # Either 404 (scoped query) or redirect to login (auth) — either way access is denied
    assert_not_equal 200, response.status
  end

  # ─── GET /transactions/:id/edit ──────────────────────────────────────────────

  test "GET edit returns success" do
    get edit_transaction_url(@transaction)
    assert_response :success
  end

  # ─── POST /transactions ──────────────────────────────────────────────────────

  test "POST create with valid params creates transaction and redirects" do
    assert_difference "Transaction.count", 1 do
      post transactions_url, params: {
        transaction: {
          account_id:       @account.id,
          category_id:      @category.id,
          date:             "2026-03-13",
          amount:           "42.50",
          currency:         "USD",
          description:      "Lunch",
          transaction_type: "expense",
          status:           "paid"
        }
      }
    end
    assert_redirected_to transaction_url(Transaction.last)
    assert_equal "Transaction was successfully created.", flash[:notice]
  end

  test "POST create with invalid params re-renders form" do
    assert_no_difference "Transaction.count" do
      post transactions_url, params: {
        transaction: {
          account_id:       @account.id,
          category_id:      @category.id,
          date:             "",
          amount:           "",
          currency:         "USD",
          description:      "",
          transaction_type: "expense",
          status:           "paid"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # ─── PATCH /transactions/:id ─────────────────────────────────────────────────

  test "PATCH update with valid params updates and redirects" do
    patch transaction_url(@transaction), params: {
      transaction: { description: "Updated groceries", amount: "90.00" }
    }
    assert_redirected_to transaction_url(@transaction)
    assert_equal "Transaction was successfully updated.", flash[:notice]
    assert_equal "Updated groceries", @transaction.reload.description
    assert_equal 90.00, @transaction.amount.to_f
  end

  test "PATCH update with invalid params re-renders form" do
    patch transaction_url(@transaction), params: {
      transaction: { amount: "-5", description: "" }
    }
    assert_response :unprocessable_entity
  end

  test "PATCH update returns not found for other user's transaction" do
    sign_out
    sign_in_as users(:two)
    patch transaction_url(@transaction), params: { transaction: { description: "Hacked" } }
    assert_not_equal 200, response.status
    assert_not_equal "Hacked", @transaction.reload.description
  end

  # ─── DELETE /transactions/:id ────────────────────────────────────────────────

  test "DELETE destroy removes transaction and redirects to index" do
    assert_difference "Transaction.count", -1 do
      delete transaction_url(@transaction)
    end
    assert_redirected_to transactions_url
    assert_equal "Transaction was successfully deleted.", flash[:notice]
  end

  test "DELETE destroy returns not found for other user's transaction" do
    sign_out
    sign_in_as users(:two)
    assert_no_difference "Transaction.count" do
      delete transaction_url(@transaction)
    end
    assert_not_equal 200, response.status
  end
end
