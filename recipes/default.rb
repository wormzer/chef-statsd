include_recipe "git"
include_recipe "nodejs"

git node["statsd"]["dir"] do
  repository node["statsd"]["repository"]
  action :sync
end

directory node["statsd"]["conf_dir"] do
  action :create
end

template "#{node["statsd"]["conf_dir"]}/config.js" do
  mode "0644"
  source "config.js.erb"
  variables(
    :port           => node["statsd"]["port"],
    :flush_interval => node["statsd"]["flush_interval"],
    :graphite_port  => node["statsd"]["graphite_port"],
    :graphite_host  => node["statsd"]["graphite_host"]
  )
  notifies :restart, "service[statsd]"
end

directory "#{node["statsd"]["dir"]}/scripts" do
  action :create
end

template "#{node["statsd"]["dir"]}/scripts/start" do
  source "start.erb"
  mode 0755
  variables(
    :log_file => node["statsd"]["log_file"]
  )
end

template "/etc/init/statsd.conf" do
  mode "0644"
  source "statsd.conf.erb"
end

user "statsd" do
  system true
  shell "/bin/false"
end

file node["statsd"]["log_file"] do
  owner "statsd"
  action :create
end

service "statsd" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
end