class CreateChooses < ActiveRecord::Migration[5.2]
  def change
    create_table :chooses do |t|
      t.references :questionnaire, foreign_key: true, null: false, comment: 'アンケートID'
      t.references :choice, foreign_key: true, comment: '選択肢ID'

      t.timestamps
    end
  end
end
