class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :asset, null: true, foreign_key: true
      t.references :recurring_template, null: true, foreign_key: true
      t.date :date, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :currency, null: false
      t.string :description, null: false
      t.text :notes
      t.string :transaction_type, null: false
      t.string :status, null: false, default: "paid"
      t.decimal :exchange_rate, precision: 10, scale: 6

      t.timestamps
    end
  end
end
