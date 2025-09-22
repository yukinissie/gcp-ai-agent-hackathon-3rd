class AddContentToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :content, :text, null: false
    add_column :articles, :content_format, :string, default: 'markdown', null: false
    
    add_index :articles, :content_format
  end
end
