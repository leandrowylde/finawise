require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  # ── Fixtures ────────────────────────────────────────────────────────────────
  def housing   = categories(:housing)
  def rent      = categories(:rent)
  def salary    = categories(:salary)
  def transfer  = categories(:transfer)
  def custom    = categories(:custom_expense)

  # ── Validations ─────────────────────────────────────────────────────────────
  test "valid with all required attributes" do
    category = Category.new(name: "Test", transaction_type: "expense")
    assert category.valid?
  end

  test "invalid without name" do
    category = Category.new(transaction_type: "expense")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "invalid without transaction_type" do
    category = Category.new(name: "Test")
    assert_not category.valid?
    assert_includes category.errors[:transaction_type], "can't be blank"
  end

  test "invalid with unknown transaction_type" do
    category = Category.new(name: "Test", transaction_type: "other")
    assert_not category.valid?
  end

  test "valid transaction_types are income expense and both" do
    %w[income expense both].each do |type|
      category = Category.new(name: "Test", transaction_type: type)
      assert category.valid?, "Expected #{type} to be valid"
    end
  end

  # ── Associations ─────────────────────────────────────────────────────────────
  test "may belong to a user (user-defined category)" do
    assert_equal users(:alice), custom.user
  end

  test "system categories have no user" do
    assert_nil housing.user
  end

  test "subcategory belongs to a parent" do
    assert_equal housing, rent.parent
  end

  test "parent has many subcategories" do
    assert_includes housing.subcategories, rent
  end

  test "top-level category has no parent" do
    assert_nil housing.parent
  end

  # ── Predefined flag ──────────────────────────────────────────────────────────
  test "predefined is false by default" do
    category = Category.new
    assert_not category.predefined?
  end

  test "system categories are predefined" do
    assert housing.predefined?
  end

  test "user-defined categories are not predefined" do
    assert_not custom.predefined?
  end

  # ── Scopes ───────────────────────────────────────────────────────────────────
  test "system scope returns categories without a user" do
    system_cats = Category.system
    assert_includes system_cats, housing
    assert_not_includes system_cats, custom
  end

  test "custom scope returns categories belonging to a user" do
    custom_cats = Category.custom
    assert_includes custom_cats, custom
    assert_not_includes custom_cats, housing
  end

  test "for_income scope includes income and both categories" do
    income_cats = Category.for_income
    assert_includes income_cats, salary
    assert_includes income_cats, transfer
    assert_not_includes income_cats, housing
  end

  test "for_expense scope includes expense and both categories" do
    expense_cats = Category.for_expense
    assert_includes expense_cats, housing
    assert_includes expense_cats, transfer
    assert_not_includes expense_cats, salary
  end

  test "top_level scope returns categories without a parent" do
    top = Category.top_level
    assert_includes top, housing
    assert_not_includes top, rent
  end

  # ── Instance predicates ──────────────────────────────────────────────────────
  test "subcategory? returns true when parent exists" do
    assert rent.subcategory?
  end

  test "subcategory? returns false for top-level categories" do
    assert_not housing.subcategory?
  end

  test "system? returns true when user is nil" do
    assert housing.system?
  end

  test "system? returns false for user-owned categories" do
    assert_not custom.system?
  end
end
