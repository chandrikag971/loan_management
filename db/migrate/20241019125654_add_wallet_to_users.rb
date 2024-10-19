class AddWalletToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :wallet, :decimal, default: 0.0
    add_column :users, :admin, :boolean, default: false
  end
end
