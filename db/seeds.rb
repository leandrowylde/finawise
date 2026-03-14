# db/seeds.rb — idempotent seed data for predefined system categories
# System categories have user_id = nil and predefined = true.
# Run with: bin/rails db:seed

SYSTEM_CATEGORIES = [
  # ── Expense categories ──────────────────────────────────────────────────
  {
    name: "Housing", icon: "house", color: "#4A90D9", transaction_type: "expense",
    subcategories: [
      { name: "Rent / Mortgage", icon: "key",    color: "#4A90D9" },
      { name: "Utilities",       icon: "bolt",   color: "#4A90D9" },
      { name: "Maintenance",     icon: "wrench", color: "#4A90D9" }
    ]
  },
  {
    name: "Food & Dining", icon: "utensils", color: "#F5A623", transaction_type: "expense",
    subcategories: [
      { name: "Groceries",    icon: "cart-shopping", color: "#F5A623" },
      { name: "Restaurants",  icon: "fork-knife",    color: "#F5A623" },
      { name: "Coffee",       icon: "mug-hot",       color: "#F5A623" }
    ]
  },
  {
    name: "Transport", icon: "car", color: "#9B59B6", transaction_type: "expense",
    subcategories: [
      { name: "Fuel",         icon: "gas-pump", color: "#9B59B6" },
      { name: "Public Transit", icon: "bus",    color: "#9B59B6" },
      { name: "Ride Share",   icon: "taxi",     color: "#9B59B6" }
    ]
  },
  {
    name: "Health", icon: "heart-pulse", color: "#E74C3C", transaction_type: "expense",
    subcategories: [
      { name: "Medical",      icon: "stethoscope", color: "#E74C3C" },
      { name: "Pharmacy",     icon: "pills",       color: "#E74C3C" },
      { name: "Gym & Fitness", icon: "dumbbell",   color: "#E74C3C" }
    ]
  },
  {
    name: "Entertainment", icon: "film", color: "#1ABC9C", transaction_type: "expense",
    subcategories: [
      { name: "Streaming",  icon: "tv",          color: "#1ABC9C" },
      { name: "Games",      icon: "gamepad",     color: "#1ABC9C" },
      { name: "Events",     icon: "ticket",      color: "#1ABC9C" }
    ]
  },
  {
    name: "Education", icon: "graduation-cap", color: "#3498DB", transaction_type: "expense",
    subcategories: [
      { name: "Courses",    icon: "book-open", color: "#3498DB" },
      { name: "Books",      icon: "book",      color: "#3498DB" }
    ]
  },
  {
    name: "Shopping", icon: "bag-shopping", color: "#E67E22", transaction_type: "expense",
    subcategories: [
      { name: "Clothing",     icon: "shirt",      color: "#E67E22" },
      { name: "Electronics",  icon: "laptop",     color: "#E67E22" }
    ]
  },
  {
    name: "Travel", icon: "plane", color: "#27AE60", transaction_type: "expense"
  },
  {
    name: "Taxes & Fees", icon: "receipt", color: "#95A5A6", transaction_type: "expense"
  },
  {
    name: "Other Expense", icon: "ellipsis", color: "#BDC3C7", transaction_type: "expense"
  },

  # ── Income categories ───────────────────────────────────────────────────
  {
    name: "Salary", icon: "briefcase", color: "#2ECC71", transaction_type: "income",
    subcategories: [
      { name: "Primary Job",  icon: "building", color: "#2ECC71" },
      { name: "Side Income",  icon: "coins",    color: "#2ECC71" }
    ]
  },
  {
    name: "Investments", icon: "chart-line", color: "#F39C12", transaction_type: "income",
    subcategories: [
      { name: "Dividends",    icon: "money-bill-trend-up", color: "#F39C12" },
      { name: "Capital Gains", icon: "arrow-trend-up",     color: "#F39C12" }
    ]
  },
  {
    name: "Freelance", icon: "laptop-code", color: "#8E44AD", transaction_type: "income"
  },
  {
    name: "Rental Income", icon: "house-circle-check", color: "#16A085", transaction_type: "income"
  },
  {
    name: "Gifts Received", icon: "gift", color: "#E91E63", transaction_type: "income"
  },
  {
    name: "Other Income", icon: "ellipsis", color: "#BDC3C7", transaction_type: "income"
  },

  # ── Transfer (used for both income & expense sides of a transfer) ────────
  {
    name: "Transfer", icon: "arrow-right-arrow-left", color: "#7F8C8D", transaction_type: "both"
  }
].freeze

puts "Seeding predefined categories..."

SYSTEM_CATEGORIES.each do |attrs|
  subcategories = attrs.delete(:subcategories) || []

  parent = Category.find_or_create_by!(
    name: attrs[:name], user_id: nil
  ) do |c|
    c.assign_attributes(attrs.merge(predefined: true))
  end

  subcategories.each do |sub_attrs|
    Category.find_or_create_by!(
      name: sub_attrs[:name], parent_id: parent.id, user_id: nil
    ) do |c|
      c.assign_attributes(
        sub_attrs.merge(
          transaction_type: parent.transaction_type,
          predefined: true
        )
      )
    end
  end
end

puts "  → #{Category.system.count} system categories created (#{Category.system.top_level.count} top-level, #{Category.system.where.not(parent_id: nil).count} subcategories)"
