require "rails_helper"

RSpec.describe RssFetchBatchJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    context "正常系" do
      let!(:active_feed1) { create(:feed, status: "active") }
      let!(:active_feed2) { create(:feed, status: "active") }
      let!(:inactive_feed) { create(:feed, status: "inactive") }

      before do
        allow(active_feed1).to receive(:fetch_articles).and_return(3)
        allow(active_feed2).to receive(:fetch_articles).and_return(2)
      end

      it "アクティブなフィードのみを処理すること" do
        # Feedのスコープをモック
        active_feeds = Feed.where(id: [ active_feed1.id, active_feed2.id ])
        allow(Feed).to receive(:active).and_return(active_feeds)
        allow(active_feeds).to receive(:find_each).and_yield(active_feed1).and_yield(active_feed2)

        result = RssFetchBatchJob.perform_now

        expect(result[:total_feeds]).to eq(2)
        expect(active_feed1).to have_received(:fetch_articles)
        expect(active_feed2).to have_received(:fetch_articles)
      end

      it "処理結果のサマリーを返すこと" do
        active_feeds = Feed.where(id: [ active_feed1.id, active_feed2.id ])
        allow(Feed).to receive(:active).and_return(active_feeds)
        allow(active_feeds).to receive(:find_each).and_yield(active_feed1).and_yield(active_feed2)

        result = RssFetchBatchJob.perform_now

        expect(result[:total_feeds]).to eq(2)
        expect(result[:successful_feeds]).to eq(2)
        expect(result[:failed_feeds]).to eq(0)
        expect(result[:total_articles_created]).to eq(5)
        expect(result[:errors]).to be_empty
      end
    end

    context "一部のフィードでエラーが発生した場合" do
      let!(:active_feed1) { create(:feed, status: "active") }
      let!(:active_feed2) { create(:feed, status: "active") }

      before do
        allow(active_feed1).to receive(:fetch_articles).and_return(3)
        allow(active_feed2).to receive(:fetch_articles).and_raise(StandardError, "Parse error")
      end

      it "エラーが発生してもジョブ全体は継続すること" do
        active_feeds = Feed.where(id: [ active_feed1.id, active_feed2.id ])
        allow(Feed).to receive(:active).and_return(active_feeds)
        allow(active_feeds).to receive(:find_each).and_yield(active_feed1).and_yield(active_feed2)

        expect {
          RssFetchBatchJob.perform_now
        }.not_to raise_error
      end

      it "エラー情報を結果に含めること" do
        active_feeds = Feed.where(id: [ active_feed1.id, active_feed2.id ])
        allow(Feed).to receive(:active).and_return(active_feeds)
        allow(active_feeds).to receive(:find_each).and_yield(active_feed1).and_yield(active_feed2)

        result = RssFetchBatchJob.perform_now

        expect(result[:total_feeds]).to eq(2)
        expect(result[:successful_feeds]).to eq(1)
        expect(result[:failed_feeds]).to eq(1)
        expect(result[:total_articles_created]).to eq(3)
        expect(result[:errors].size).to eq(1)
        expect(result[:errors].first).to include(
          feed_id: active_feed2.id,
          title: active_feed2.title,
          error: "Parse error"
        )
      end
    end

    context "アクティブなフィードが存在しない場合" do
      before do
        Feed.update_all(status: "inactive")
      end

      it "空の結果を返すこと" do
        result = RssFetchBatchJob.perform_now

        expect(result[:total_feeds]).to eq(0)
        expect(result[:successful_feeds]).to eq(0)
        expect(result[:failed_feeds]).to eq(0)
        expect(result[:total_articles_created]).to eq(0)
        expect(result[:errors]).to be_empty
      end
    end

    describe "ジョブのキュー設定" do
      it "defaultキューを使用すること" do
        expect(RssFetchBatchJob.new.queue_name).to eq("default")
      end

      it "非同期実行できること" do
        expect {
          RssFetchBatchJob.perform_later
        }.to have_enqueued_job(RssFetchBatchJob)
          .on_queue("default")
      end
    end
  end
end
