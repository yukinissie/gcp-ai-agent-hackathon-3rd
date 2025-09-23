class AddRssFieldsToArticles < ActiveRecord::Migration[8.0]
  def change
    add_reference :articles, :feed, null: true, foreign_key: true, comment: 'RSS由来の記事の場合のフィード参照'
    add_column :articles, :source_type, :string, default: 'manual', null: false, comment: '記事の作成元'

    # インデックス追加
    add_index :articles, :source_type, comment: 'ソース種別での絞り込み用'
    add_index :articles, [ :feed_id, :created_at ], comment: 'フィード別記事一覧用'

    # RSS記事の重複防止（条件付きユニーク制約）
    add_index :articles, [ :feed_id, :source_url ],
              unique: true,
              where: "source_type = 'rss' AND source_url IS NOT NULL",
              name: 'index_articles_on_feed_and_source_url_for_rss',
              comment: 'RSS記事の重複防止'
  end
end
