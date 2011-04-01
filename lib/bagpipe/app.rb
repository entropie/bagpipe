#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


module Config
  class << self

    attr_accessor :repos
    attr_accessor :adapter

    def server
      @server ||= {}
    end

    def repos
      @repos || File.expand_path(".")
    end

    def adapter
      @adapter || :webrick
    end

    def setup
      yield self
    end
  end
end

# Orignal idea by Ryan Grove <ryan@wonko.com>
# https://github.com/rgrove/thoth/blob/master/lib/thoth.rb
# Modified by me to fit my needs.
module Bagpipe::App
  include Innate::Traited

  HOME_DIR   = Bagpipe::Source unless const_defined?(:HOME_DIR)
  LIB_DIR    = File.join(HOME_DIR, 'lib')
  APP_DIR    = File.join(HOME_DIR, 'app')
  PUBLIC_DIR = 'public' unless const_defined?(:PUBLIC_DIR)
  VIEW_DIR   = 'view' unless const_defined?(:VIEW_DIR)

  trait(:traits_broken => true)
  trait[:adapter]    ||= nil
  trait[:daemon]     ||= nil
  trait[:ip]         ||= nil
  trait[:irb]        ||= false
  trait[:mode]       ||= :production
  trait[:port]       ||= nil
  trait[:repos]      ||= nil
  trait[:pidfile]    ||= File.join("/tmp/", "bagpipe.pid")

  module Helper; end

  class << self

    def init_bagpipe
      trait[:ip]      ||= Config.server['address']
      trait[:port]    ||= Config.server['port']
      trait[:repos]   ||= Config.repos
      trait[:adapter] ||= Config.adapter

      Ramaze::Log.info "Bagpipe home   : #{HOME_DIR}"
      Ramaze::Log.info "Bagpipe lib    : #{LIB_DIR}"
      Ramaze::Log.info "Bagpipe app    : #{APP_DIR}"
      Ramaze::Log.info "Bagpipe view   : #{VIEW_DIR}"
      Ramaze::Log.info "Bagpipe public : #{PUBLIC_DIR}"
      Ramaze::Log.info "Running in #{trait[:mode] == :production ? 'live' : 'dev'} mode"

      Ramaze.options.setup << self
    end

    # Restarts the running Bagpipe daemon (if any).
    def restart
      stop
      sleep(1)
      start
    end

    # Runs Bagpipe.
    def run
      init_bagpipe
      begin
        Ramaze.start(
          :adapter => trait[:adapter],
          :host    => trait[:ip],
          :port    => trait[:port],
          :root    => APP_DIR
        )
      rescue LoadError => ex
        Ramaze::Log.error("Unable to start Ramaze due to LoadError: #{ex}")
        exit(1)
      end
    end

    # Initializes Ramaze.
    def setup
      Ramaze.options.merge!(
        :mode  => trait[:mode] == :production ? :live : :dev,
        :roots => [APP_DIR]
      )

      case trait[:mode]
      when :devel
        Ramaze.middleware!(:dev) do |m|
          m.use Rack::Lint
          m.use Rack::CommonLogger, Ramaze::Log
          m.use Rack::ShowExceptions
          m.use Rack::ShowStatus
          m.use Rack::RouteExceptions
          m.use Rack::ConditionalGet
          m.use Rack::ETag
          m.use Rack::Head
          m.use Ramaze::Reloader
          m.run Ramaze::AppMap
        end
      when :production
        Ramaze.middleware!(:live) do |m|
          m.use Rack::CommonLogger, Ramaze::Log
          m.use Rack::RouteExceptions
          m.use Rack::ShowStatus
          m.use Rack::ConditionalGet
          m.use Rack::ETag
          m.use Rack::Head
          m.run Ramaze::AppMap
        end

        # Ensure that exceptions result in an HTTP 500 response.
        Rack::RouteExceptions.route(Exception, '/error_500')

        # Log all errors to the error log file if one is configured.
        if Config.server['error_log'].empty?
          Ramaze::Log.loggers = []
        else
          log_dir = File.dirname(Config.server['error_log'])

          unless File.directory?(log_dir)
            FileUtils.mkdir_p(log_dir)
            File.chmod(0750, log_dir)
          end

        end
      end
    end

    # Starts Bagpipe as a daemon.
    def start
      if File.file?(trait[:pidfile])
        pid = File.read(trait[:pidfile], 20).strip
        abort("Bagpipe already running? (pid=#{pid})")
      end

      puts "Starting Bagpipe."

      fork do
        Process.setsid
        exit if fork

        File.open(trait[:pidfile], 'w') {|file| file << Process.pid}
        at_exit {FileUtils.rm(trait[:pidfile]) if File.exist?(trait[:pidfile])}

        Dir.chdir(HOME_DIR)
        File.umask(0000)

        STDIN.reopen('/dev/null')
        STDOUT.reopen('/dev/null', 'a')
        STDERR.reopen(STDOUT)

        run
      end
    end

    # Stops the running Bagpipe daemon (if any).
    def stop
      unless File.file?(trait[:pidfile])
        abort("Bagpipe not running? (check #{trait[:pidfile]}).")
      end

      puts "Stopping Bagpipe."

      pid = File.read(trait[:pidfile], 20).strip
      FileUtils.rm(trait[:pidfile]) if File.exist?(trait[:pidfile])
      pid && Process.kill('SIGKILL', pid.to_i)
    end
  end
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
