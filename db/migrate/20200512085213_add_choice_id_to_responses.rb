class AddChoiceIdToResponses < ActiveRecord::Migration[5.2]
  def change
    add_reference :responses, :choice, foreign_key: true, null: false, comment: '選んだ選択肢'
  end
end
