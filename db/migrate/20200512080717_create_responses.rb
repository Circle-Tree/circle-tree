class CreateResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :responses do |t|
      t.references :questionnaire, foreign_key: true, null: false, comment: 'アンケートID'
      t.references :user, foreign_key: true, null: false, comment: '回答者'

      t.timestamps
    end
  end
end
