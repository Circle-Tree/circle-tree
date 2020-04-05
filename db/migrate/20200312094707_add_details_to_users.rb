class AddDetailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gender, :boolean, comment: '性別'
    add_column :users, :grade, :integer, comment: '学年'
    add_column :users, :furigana, :string, comment: 'フリガナ'
    add_index :users, :furigana
  end
end
