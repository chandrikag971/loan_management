class AddDefaultToAmount < ActiveRecord::Migration[7.0]
  def change
    change_column :loans, :amount, :decimal, default: 0.0
  end
end
