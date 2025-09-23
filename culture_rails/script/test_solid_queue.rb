# SolidQueueの動作テスト

puts "=== SolidQueue Configuration Test ==="

# 1. ActiveJob設定確認
puts "ActiveJob adapter: #{Rails.application.config.active_job.queue_adapter}"

# 2. SolidQueue テーブル確認
tables = ActiveRecord::Base.connection.execute(
  "SELECT tablename FROM pg_tables WHERE tablename LIKE 'solid_queue%'"
).to_a.map { |row| row['tablename'] }

puts "SolidQueue tables: #{tables.size} found"
tables.each { |table| puts "  - #{table}" }

# 3. RecurringTask確認
puts "\nRecurringTasks:"
SolidQueue::RecurringTask.all.each do |task|
  puts "  - #{task.key}: #{task.schedule} (#{task.class_name})"
end

# 4. テストジョブをエンキュー
puts "\n=== Testing Job Enqueue ==="
job = RssFetchBatchJob.perform_later
puts "Job enqueued: ID=#{job.job_id}, Queue=#{job.queue_name}"

# 5. ジョブキューの状況確認
ready_jobs = SolidQueue::Job.where(finished_at: nil).count
puts "Jobs in queue: #{ready_jobs}"

# 6. フィード状況確認
puts "\n=== Feed Status ==="
puts "Total feeds: #{Feed.count}"
puts "Active feeds: #{Feed.active.count}"
Feed.all.each do |feed|
  puts "  - [#{feed.status}] #{feed.title}"
end

puts "\n=== Test completed ==="