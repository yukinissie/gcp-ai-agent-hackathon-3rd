class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :summary, null: false
      t.string :author, null: false
      t.string :source_url
      t.string :image_url
      t.boolean :published, default: false, null: false
      t.datetime :published_at

      t.timestamps
    end
    
    add_index :articles, :published
    add_index :articles, :published_at
    add_index :articles, [:published, :published_at]
  end
end
