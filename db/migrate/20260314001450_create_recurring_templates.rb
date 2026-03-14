class CreateRecurringTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_templates do |t|
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :description
      t.decimal :amount
      t.string :currency
      t.string :frequency
      t.date :next_due_date
      t.string :transaction_type

      t.timestamps
    end
  end
end
