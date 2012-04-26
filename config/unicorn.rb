worker_processes 3 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
preload_app true

after_fork {|server,worker| ActiveRecord::Base.establish_connection }