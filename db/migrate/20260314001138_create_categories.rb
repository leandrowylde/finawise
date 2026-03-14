class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :icon
      t.string :color
      t.string :transaction_type, null: false
      t.boolean :predefined, null: false, default: false
      t.references :user, null: true, foreign_key: true  # nil = system/predefined category
      t.integer :parent_id, index: true

      t.timestamps
    end

    add_index :categories, :predefined
  end
end
