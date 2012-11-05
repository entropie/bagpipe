#!/usr/bin/env ruby
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "optparse"
require "pp"

$:.unshift File.join(File.dirname(__FILE__), "../lib")
$:.unshift File.join(File.dirname(__FILE__), "../app")

require "bagpipe"

help = ""

default_options = {
  :port     => 8100,
  :hostname => "0.0.0.0",
  :repos    => File.expand_path("."),
  :adapter  => :webrick,
  :elog     => File.join(File.expand_path("~"), "/.bagpipe/", "error_log.log")
}

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on("-d", "--daemon [start|stop|restart]", "Daemonizes Bagpipe. Default argument is 'start'") do |arg|
    arg ||= "start"
    default_options[:daemon] = arg
  end

  opts.on("-p", "--port [PORT]", "Application port (default 8200)") do |port|
    default_options[:port] = port.to_i
  end

  opts.on("-h", "--hostname [HOST]", "Application hostname (default localhost)") do |hn|
    default_options[:hostname] = hn
  end

  opts.on("-r", "--repos [REPOS]", "Start Bagpipe with with [REPOS] (default is `pwd`)") do |repos|
    repos_path = File.expand_path(repos)
    raise unless File.exist?(repos_path)
    default_options[:repos] = repos_path
  end

end


begin
  opts.parse!
rescue OptionParser::InvalidOption
  puts "bagpipe: #{$!.message}"
  puts "bagpipe: try 'oy --help' for more information"
  exit 1
end

require "start"
require "bagpipe/app"

# FIXME: this stuff needs to live in oy/oy.rb
begin
  Bagpipe.path = default_options[:repos]

  # FIXME:
  $VERBOSE = nil # turn off sass deprecation warnings

  Config.setup do |cfg|
    cfg.repos               = default_options[:repos]
    cfg.adapter             = default_options[:adapter]
    cfg.server["address"]   = default_options[:hostname]
    cfg.server["port"]      = default_options[:port]
    cfg.server["error_log"] = default_options[:elog]
    cfg.server["daemon"]    = default_options[:daemon]
  end

  Bagpipe.url = "#{default_options[:hostname]}:#{default_options[:port]}"

  module Bagpipe::App
    trait[:mode] = :devel
    trait[:adapter] = :mongrel
    what = Config.server["daemon"] || :run
    send(what)
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
