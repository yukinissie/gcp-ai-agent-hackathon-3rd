class CreateArticleTaggings < ActiveRecord::Migration[8.0]
  def change
    create_table :article_taggings do |t|
      t.references :article, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :article_taggings, [ :article_id, :tag_id ], unique: true
  end
end
