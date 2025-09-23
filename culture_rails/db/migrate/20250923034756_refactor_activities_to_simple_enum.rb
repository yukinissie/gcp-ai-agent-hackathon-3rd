class RefactorActivitiesToSimpleEnum < ActiveRecord::Migration[8.0]
  def up
    # 既存データを削除（開発環境なので安全）
    Activity.delete_all

    # actionカラムを削除
    remove_column :activities, :action

    # activity_typeをnullableにする（評価なしを表現）
    change_column_null :activities, :activity_type, true

    # ユーザー・記事の組み合わせで一意制約を追加
    add_index :activities, [ :user_id, :article_id ], unique: true
  end

  def down
    # ロールバック時の処理
    remove_index :activities, [ :user_id, :article_id ]
    change_column_null :activities, :activity_type, false
    add_column :activities, :action, :integer, null: false, default: 0
  end
end
