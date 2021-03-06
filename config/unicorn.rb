worker_processes 3

listen File.expand_path("/tmp/unicorn_library-miner-web-api.sock", ENV['MINER_WEB_API_ROOT'])
pid File.expand_path("/tmp/unicorn.pid", ENV['MINER_WEB_API_ROOT'])

timeout 60

preload_app true

stdout_path File.expand_path("log/unicorn.stdout.log", ENV['MINER_WEB_API_ROOT'])
stderr_path File.expand_path("log/unicorn.stderr.log", ENV['MINER_WEB_API_ROOT'])

GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  sleep 1
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
