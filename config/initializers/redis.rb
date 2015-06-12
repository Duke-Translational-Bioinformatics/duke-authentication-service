$redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])
Rails.application.config.token_ttl = 4 * 60 * 60
