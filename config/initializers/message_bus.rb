MessageBus.site_id_lookup do
  RailsMultisite::ConnectionManagement.current_db
end

MessageBus.user_id_lookup do |env|
  user = CurrentUser.lookup_from_env(env)
  user.id if user
end

MessageBus.on_connect do |site_id|
  RailsMultisite::ConnectionManagement.establish_connection(:db => site_id)
end

MessageBus.on_disconnect do |site_id|
  ActiveRecord::Base.connection_handler.clear_active_connections!
end

# Point at our redis
MessageBus.redis_config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env].symbolize_keys

MessageBus.long_polling_enabled = SiteSetting.enable_long_polling
MessageBus.long_polling_interval = SiteSetting.long_polling_interval

MessageBus.is_admin_lookup do |env|
  user = CurrentUser.lookup_from_env(env)
  if user && user.admin
    true
  else
    false
  end
end

MessageBus.cache_assets = !Rails.env.development?
MessageBus.enable_diagnostics
