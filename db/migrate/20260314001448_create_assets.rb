class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :asset_type
      t.date :purchase_date
      t.decimal :purchase_price
      t.string :currency
      t.text :description

      t.timestamps
    end
  end
end
