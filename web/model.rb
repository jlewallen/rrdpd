names = %w(category configuration counter_type data_manager database graph grapher item rrd source user)
names.each do |file|
  require "web/models/#{file}"
end
