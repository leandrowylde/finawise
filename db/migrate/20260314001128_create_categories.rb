class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :user, null: true, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :categories }
      t.string :name, null: false
      t.string :icon
      t.string :color
      t.string :transaction_type, null: false
      t.boolean :predefined, null: false, default: false

      t.timestamps
    end
  end
end
