class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.integer :activity_type, null: false
      t.integer :action, null: false

      t.timestamps
    end

    # 履歴保持のためユニーク制約なし
    add_index :activities, [ :user_id, :article_id, :activity_type, :created_at ], name: 'index_activities_on_user_article_type_time'
    add_index :activities, [ :user_id, :created_at ]
    add_index :activities, [ :article_id, :activity_type, :created_at ]
    add_index :activities, :activity_type
    add_index :activities, :action
  end
end
