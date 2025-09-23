# == Schema Information
#
# Table name: articles
#
#  id                                         :bigint           not null, primary key
#  author                                     :string           not null
#  content                                    :text             not null
#  content_format                             :string           default("markdown"), not null
#  image_url                                  :string
#  published                                  :boolean          default(FALSE), not null
#  published_at                               :datetime
#  source_type(記事の作成元)                  :string           default("manual"), not null
#  source_url                                 :string
#  summary                                    :text             not null
#  title                                      :string           not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  feed_id(RSS由来の記事の場合のフィード参照) :bigint
#
# Indexes
#
#  index_articles_on_content_format               (content_format)
#  index_articles_on_feed_and_source_url_for_rss  (feed_id,source_url) UNIQUE WHERE (((source_type)::text = 'rss'::text) AND (source_url IS NOT NULL))
#  index_articles_on_feed_id                      (feed_id)
#  index_articles_on_feed_id_and_created_at       (feed_id,created_at)
#  index_articles_on_published                    (published)
#  index_articles_on_published_and_published_at   (published,published_at)
#  index_articles_on_published_at                 (published_at)
#  index_articles_on_source_type                  (source_type)
#
# Foreign Keys
#
#  fk_rails_...  (feed_id => feeds.id)
#
require 'rails_helper'

RSpec.describe Article, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
