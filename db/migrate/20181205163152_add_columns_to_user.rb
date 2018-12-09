class AddColumnsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :uin, :integer
    add_column :users, :password, :string
    add_column :users, :isapproved, :boolean
  end
end
