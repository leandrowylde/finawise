class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :account_type, null: false
      t.string :currency, null: false
      t.decimal :balance, precision: 15, scale: 2, null: false, default: 0
      t.string :institution_name

      t.timestamps
    end
    add_index :accounts, :name
  end
end
