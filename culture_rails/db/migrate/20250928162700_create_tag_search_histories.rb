class CreateTagSearchHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_search_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :article_ids, null: false, default: [], array: true
      t.timestamps
    end

    add_index :tag_search_histories, [:user_id, :created_at]
    add_index :tag_search_histories, :article_ids, using: :gin
  end
end
