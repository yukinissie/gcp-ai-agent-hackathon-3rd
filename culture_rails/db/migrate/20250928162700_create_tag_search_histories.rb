class CreateTagSearchHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :tag_search_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :article_ids, null: false, default: [], array: true
      t.datetime :searched_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamps
    end

    add_index :tag_search_histories, :searched_at
    add_index :tag_search_histories, [:user_id, :searched_at]
    add_index :tag_search_histories, :article_ids, using: :gin
  end
end
