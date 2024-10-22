class AddPrincipalToLoan < ActiveRecord::Migration[7.0]
  def change
    add_column :loans, :principal, :decimal, default: 0.0
  end
end
