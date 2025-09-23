# SolidQueueのRecurringTaskを手動で登録

puts "=== Setting up SolidQueue Recurring Tasks ==="

# 開発環境用の15分ごと実行
development_task = SolidQueue::RecurringTask.find_or_create_by(
  key: "rss_batch_fetch"
) do |task|
  task.schedule = "every 15 minutes"
  task.class_name = "RssFetchBatchJob"
  task.queue_name = "default"
  task.description = "全てのアクティブなRSSフィードから記事を取得"
  task.static = true
end

puts "Created/Updated recurring task: #{development_task.key}"
puts "Schedule: #{development_task.schedule}"
puts "Class: #{development_task.class_name}"

# RecurringTask数確認
puts "\nTotal RecurringTasks: #{SolidQueue::RecurringTask.count}"

SolidQueue::RecurringTask.all.each do |task|
  puts "- #{task.key}: #{task.schedule} (#{task.class_name})"
end

puts "=== Setup completed ==="