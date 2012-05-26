require 'resque/tasks'

module Resque
  class Launcher
    def self.start
      if ENV['PIDFILE']
        File.open(ENV['PIDFILE'], 'w') { |f| f << Process.pid }
      end

      Rake::Task['resque:preload'].invoke
      Rake::Task['resque:setup'].invoke

      require 'resque'

      queues = (ENV['QUEUES'] || ENV['QUEUE']).to_s.split(',')

      begin
        worker = Resque::Worker.new(*queues)
        worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
        worker.very_verbose = ENV['VVERBOSE']
      rescue Resque::NoQueueError
        abort "set QUEUE env var, e.g. $ QUEUE=critical,high rake resque:work"
      end

      if ENV['BACKGROUND']
        unless Process.respond_to?('daemon')
          abort "env var BACKGROUND is set, which requires ruby >= 1.9"
        end
        Process.daemon(true)
      end

      worker.log "Starting worker #{worker}"

      worker.work(ENV['INTERVAL'] || 5) # interval, will block
    end
  end
end
