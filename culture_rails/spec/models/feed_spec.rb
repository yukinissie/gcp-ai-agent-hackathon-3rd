require 'rails_helper'

RSpec.describe Feed, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  describe 'バリデーション' do
    it 'タイトルが必要であること' do
      feed = build(:feed, title: nil)
      expect(feed).to_not be_valid
      expect(feed.errors[:title]).to include("can't be blank")
    end

    it 'エンドポイントが必要であること' do
      feed = build(:feed, endpoint: nil)
      expect(feed).to_not be_valid
      expect(feed.errors[:endpoint]).to include("can't be blank")
    end

    it 'エンドポイントが有効なURLである必要があること' do
      feed = build(:feed, endpoint: 'invalid-url')
      expect(feed).to_not be_valid
      expect(feed.errors[:endpoint]).to include("is invalid")
    end

    it 'エンドポイントがユニークである必要があること' do
      existing_feed = create(:feed, endpoint: 'https://example.com/rss.xml')
      duplicate_feed = build(:feed, endpoint: 'https://example.com/rss.xml')

      expect(duplicate_feed).to_not be_valid
      expect(duplicate_feed.errors[:endpoint]).to include("has already been taken")
    end
  end

  describe 'ステータス' do
    it 'デフォルトでactiveステータスになること' do
      feed = create(:feed)
      expect(feed.status).to eq('active')
    end

    it '各ステータスが正しく設定できること' do
      feed = create(:feed)

      feed.active!
      expect(feed.status).to eq('active')

      feed.inactive!
      expect(feed.status).to eq('inactive')

      feed.error!
      expect(feed.status).to eq('error')
    end
  end

  describe 'RSSパース機能' do
    let(:feed) { create(:feed, endpoint: 'https://example.com/rss.xml') }
    let(:rss_content) { File.read(Rails.root.join('spec/fixtures/rss/sample_rss.xml')) }
    let(:atom_content) { File.read(Rails.root.join('spec/fixtures/rss/sample_atom.xml')) }

    before do
      # Net::HTTPをモック - 特定のURIに対してモックを設定
      allow(Net::HTTP).to receive(:get).with(URI.parse(feed.endpoint)).and_return(rss_content)
    end

    describe '#parsed_xml' do
      context 'RSSフィードの場合' do
        it 'XMLが正常にパースされること' do
          doc = feed.parsed_xml

          expect(doc).to be_a(Nokogiri::XML::Document)
          expect(doc.xpath('//channel/title').text).to eq('テックブログサンプル')
          expect(doc.xpath('//item').size).to eq(3)
        end

        it 'フィードのステータスがactiveのままであること' do
          feed.parsed_xml
          feed.reload
          expect(feed.status).to eq('active')
        end
      end

      context 'Atomフィードの場合' do
        before do
          allow(Net::HTTP).to receive(:get).and_return(atom_content)
        end

        it 'Atomが正常にパースされること' do
          doc = feed.parsed_xml

          expect(doc).to be_a(Nokogiri::XML::Document)
          expect(doc.xpath('//atom:feed/atom:title', 'atom' => 'http://www.w3.org/2005/Atom').text).to eq('デザインブログサンプル')
          expect(doc.xpath('//atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size).to eq(2)
        end
      end

      context 'パースエラーの場合' do
        before do
          allow(Net::HTTP).to receive(:get).and_return('invalid xml content')
        end

        it 'nilが返されること' do
          doc = feed.parsed_xml
          expect(doc).to be_nil
        end

        it 'ステータスがerrorになること' do
          feed.parsed_xml
          feed.reload
          expect(feed.status).to eq('error')
          expect(feed.last_error).to be_present
        end
      end

      context 'ネットワークエラーの場合' do
        before do
          allow(Net::HTTP).to receive(:get).and_raise(SocketError.new('Network error'))
        end

        it 'nilが返されること' do
          doc = feed.parsed_xml
          expect(doc).to be_nil
        end

        it 'ステータスがerrorになること' do
          feed.parsed_xml
          feed.reload
          expect(feed.status).to eq('error')
          expect(feed.last_error).to eq('Network error')
        end
      end
    end

    describe '#update_title_from_xml' do
      it 'XMLからフィードタイトルが更新されること' do
        feed.update_title_from_xml
        feed.reload
        expect(feed.title).to eq('テックブログサンプル')
      end

      context 'XMLにタイトルがない場合' do
        before do
          allow(Net::HTTP).to receive(:get).and_return('<rss><channel></channel></rss>')
        end

        it 'タイトルが更新されないこと' do
          original_title = feed.title
          feed.update_title_from_xml
          feed.reload
          expect(feed.title).to eq(original_title)
        end
      end
    end
  end

  describe '記事取得機能' do
    let(:feed) { create(:feed, endpoint: 'https://example.com/rss.xml') }
    let(:rss_content) { File.read(Rails.root.join('spec/fixtures/rss/sample_rss.xml')) }

    before do
      # Net::HTTPをモック - 特定のURIに対してモックを設定
      allow(Net::HTTP).to receive(:get).with(URI.parse(feed.endpoint)).and_return(rss_content)
    end

    describe '#fetch_articles' do
      it '記事が正常に作成されること' do
        # 独立したフィードを作成してテスト間の影響を避ける
        test_feed = create(:feed, endpoint: 'https://example.com/article-test.xml', title: '記事作成テストフィード')
        allow(Net::HTTP).to receive(:get).with(URI.parse('https://example.com/article-test.xml')).and_return(rss_content)

        expect {
          test_feed.fetch_articles
        }.to change(Article, :count).by(3)

        articles = test_feed.articles.order(:created_at)

        # 最初の記事をチェック
        first_article = articles.first
        expect(first_article.title).to eq('Railsの最新機能について')
        expect(first_article.source_url).to eq('https://example.com/tech-blog/rails-features')
        expect(first_article.author).to eq('技術太郎')
        expect(first_article.source_type).to eq('rss')
        expect(first_article.published).to be true
      end

      it 'フィードのステータスが正しく更新されること' do
        # 独立したフィードを作成してテスト間の影響を避ける
        status_test_feed = create(:feed, endpoint: 'https://example.com/status-test.xml', title: 'ステータステストフィード')
        allow(Net::HTTP).to receive(:get).with(URI.parse('https://example.com/status-test.xml')).and_return(rss_content)

        freeze_time = Time.current
        travel_to(freeze_time) do
          status_test_feed.fetch_articles
          status_test_feed.reload

          expect(status_test_feed.status).to eq('active')
          expect(status_test_feed.last_fetched_at).to be_within(1.second).of(freeze_time)
          expect(status_test_feed.last_error).to be_nil
        end
      end

      it '自動タグが付与されること' do
        # 独立したフィードを作成してテスト間の影響を避ける
        tag_test_feed = create(:feed, endpoint: 'https://example.com/tag-test.xml', title: 'タグテストフィード')
        allow(Net::HTTP).to receive(:get).with(URI.parse('https://example.com/tag-test.xml')).and_return(rss_content)

        tag_test_feed.fetch_articles

        articles = tag_test_feed.articles
        expect(articles.count).to eq(3)

        # 各記事にフィード名のタグが付いていることを確認
        articles.each do |article|
          source_tag = article.tags.find_by(category: 'source')
          expect(source_tag).to be_present
          expect(source_tag.name).to eq(tag_test_feed.title)
        end
      end

      it '重複した記事は作成されないこと' do
        # 独立したフィードを作成してテスト間の影響を避ける
        duplicate_test_feed = create(:feed, endpoint: 'https://example.com/duplicate-test.xml', title: '重複テストフィード')
        allow(Net::HTTP).to receive(:get).with(URI.parse('https://example.com/duplicate-test.xml')).and_return(rss_content)

        # 最初に記事を作成
        expect {
          duplicate_test_feed.fetch_articles
        }.to change(Article, :count).by(3)

        # 再度実行しても記事数は増えない
        expect {
          duplicate_test_feed.fetch_articles
        }.to change(Article, :count).by(0)
      end

      context 'Atomフィードの場合' do
        let(:atom_content) { File.read(Rails.root.join('spec/fixtures/rss/sample_atom.xml')) }

        it 'Atomフィードからも記事が作成されること' do
          # 独立したフィードを作成してテスト間の影響を避ける
          atom_test_feed = create(:feed, endpoint: 'https://example.com/atom-test.xml', title: 'Atomテストフィード')
          allow(Net::HTTP).to receive(:get).with(URI.parse('https://example.com/atom-test.xml')).and_return(atom_content)

          expect {
            atom_test_feed.fetch_articles
          }.to change(Article, :count).by(2)

          articles = atom_test_feed.articles.order(:created_at)

          first_article = articles.first
          expect(first_article.title).to eq('UIデザインの基本原則')
          expect(first_article.source_url).to eq('https://example.com/design-blog/ui-principles')
          expect(first_article.author).to eq('デザイン三郎')
        end
      end

      context 'パースエラーの場合' do
        before do
          allow(Net::HTTP).to receive(:get).and_return('invalid xml')
        end

        it '記事は作成されずエラー状態になること' do
          expect {
            feed.fetch_articles
          }.to change(Article, :count).by(0)

          feed.reload
          expect(feed.status).to eq('error')
          expect(feed.last_error).to be_present
        end
      end
    end

    describe '#mark_as_fetched' do
      it '取得成功時の状態が正しく設定されること' do
        freeze_time = Time.current
        travel_to(freeze_time) do
          feed.mark_as_fetched
          feed.reload

          expect(feed.status).to eq('active')
          expect(feed.last_fetched_at).to be_within(1.second).of(freeze_time)
          expect(feed.last_error).to be_nil
        end
      end
    end

    describe '#mark_as_error' do
      it 'エラー状態が正しく設定されること' do
        error_message = 'Test error message'
        feed.mark_as_error(error_message)
        feed.reload

        expect(feed.status).to eq('error')
        expect(feed.last_error).to eq(error_message)
      end
    end
  end

  describe 'スコープ' do
    let!(:active_feed) { create(:feed, status: 'active') }
    let!(:inactive_feed) { create(:feed, status: 'inactive') }
    let!(:error_feed) { create(:feed, status: 'error') }
    let!(:recent_feed) { create(:feed, created_at: 1.hour.ago) }
    let!(:old_feed) { create(:feed, created_at: 1.day.ago) }

    describe '.active' do
      it 'アクティブなフィードのみ返すこと' do
        active_feeds = Feed.active
        expect(active_feeds).to include(active_feed)
        expect(active_feeds).to_not include(inactive_feed, error_feed)
      end
    end

    describe '.recent' do
      it '作成日時の降順で返すこと' do
        recent_feeds = Feed.recent
        expect(recent_feeds.first.created_at).to be > recent_feeds.last.created_at
      end
    end
  end

  describe "重複チェック機能" do
    let(:feed) { create(:feed) }

    before do
      # 既存記事を作成
      create(:article,
        feed: feed,
        title: "既存記事のタイトル",
        content: "既存記事の内容です。",
        source_url: "https://example.com/existing"
      )
    end

    describe "#article_exists?" do
      it "同じURLの記事は重複として検出されること" do
        expect(feed.send(:article_exists?, "https://example.com/existing")).to be true
      end

      it "異なるURLの記事は重複として検出されないこと" do
        expect(feed.send(:article_exists?, "https://example.com/new")).to be false
      end

      it "空のURLの場合はfalseを返すこと" do
        expect(feed.send(:article_exists?, "")).to be false
        expect(feed.send(:article_exists?, nil)).to be false
      end
    end
  end
end
