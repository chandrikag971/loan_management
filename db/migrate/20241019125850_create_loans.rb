class CreateLoans < ActiveRecord::Migration[7.0]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :interest_rate, precision: 5, scale: 2
      t.string :status, default: 'requested'

      t.timestamps
    end
  end
end
