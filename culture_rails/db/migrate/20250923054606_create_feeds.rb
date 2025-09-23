class CreateFeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :feeds do |t|
      t.string :title, null: false, comment: 'フィードのタイトル'
      t.string :endpoint, null: false, comment: 'RSS/AtomフィードのURL'
      t.string :status, default: 'active', null: false, comment: 'フィードの状態'
      t.datetime :last_fetched_at, comment: '最後に取得した日時'
      t.text :last_error, comment: '最後のエラーメッセージ'
      t.timestamps
    end

    # インデックス
    add_index :feeds, :endpoint, unique: true, comment: 'エンドポイントの一意性'
    add_index :feeds, :status, comment: '状態での絞り込み用'
    add_index :feeds, :last_fetched_at, comment: '取得日時でのソート用'
    add_index :feeds, :created_at, comment: '作成日時でのソート用'
  end
end
