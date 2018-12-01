class CreateChoices < ActiveRecord::Migration[5.1]
  def change
    create_table :choices do |t|
      t.integer "answers", default: [], array: true
      t.timestamps
      t.integer:student_id
      t.integer:question_id
      t.integer:eid
    end
  end
end
