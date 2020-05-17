class CreateQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaires do |t|
      t.text :content, null: false, comment: 'アンケート内容'
      t.references :user, foreign_key: true, null: false, comment: '質問した人'
      t.integer :status, default: 0, null: false, comment: 'アンケートの回答受付状態'

      t.timestamps
    end
  end
end
