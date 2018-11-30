class AddReferencesToScores < ActiveRecord::Migration[5.1]
  def change
    add_column :scores, :eid, :integer, index: true
  end
end
