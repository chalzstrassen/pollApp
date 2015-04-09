class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :answer_choice_id
      t.integer :user_id
    end

    add_index(:responses, :answer_choice_id)
    add_index(:responses, :user_id)
    
  end
end
