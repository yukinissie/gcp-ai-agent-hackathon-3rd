require "rails_helper"

RSpec.describe RssFetchSingleJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let!(:feed) { create(:feed, title: "テストフィード", endpoint: "https://example.com/rss") }

    context "正常系" do
      it "指定されたフィードの記事を取得すること" do
        allow(feed).to receive(:fetch_articles).and_return(5)
        allow(Feed).to receive(:find).with(feed.id).and_return(feed)

        expect {
          RssFetchSingleJob.perform_now(feed.id)
        }.not_to raise_error

        expect(feed).to have_received(:fetch_articles)
      end

      it "作成した記事数を返すこと" do
        allow_any_instance_of(Feed).to receive(:fetch_articles).and_return(3)

        result = RssFetchSingleJob.perform_now(feed.id)
        expect(result).to eq(3)
      end
    end

    context "異常系" do
      context "フィードが存在しない場合" do
        it "ActiveRecord::RecordNotFoundエラーを発生させること" do
          expect {
            RssFetchSingleJob.perform_now(99999)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "フィード取得中にエラーが発生した場合" do
        it "エラーを再発生させること" do
          allow_any_instance_of(Feed).to receive(:fetch_articles).and_raise(StandardError, "RSS parse error")

          expect {
            RssFetchSingleJob.perform_now(feed.id)
          }.to raise_error(StandardError, "RSS parse error")
        end
      end
    end

    describe "ジョブのキュー設定" do
      it "defaultキューを使用すること" do
        expect(RssFetchSingleJob.new.queue_name).to eq("default")
      end

      it "非同期実行できること" do
        expect {
          RssFetchSingleJob.perform_later(feed.id)
        }.to have_enqueued_job(RssFetchSingleJob)
          .with(feed.id)
          .on_queue("default")
      end
    end
  end
end
