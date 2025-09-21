class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :category, null: false

      t.timestamps
    end
    
    add_index :tags, [:name, :category], unique: true
    add_index :tags, :category
  end
end
