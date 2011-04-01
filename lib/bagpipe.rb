#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"
require "ostruct"
require "json"
require "unicode"

require "pp"

module Bagpipe

  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  Version = [0, 1, 0]

  $: << File.join(Source, "lib/bagpipe") unless $:.include?(File.join(Source, "lib/bagpipe"))
  $: << File.join(Source, "app")         unless $:.include?(File.join(Source, "app"))

  def puts(*args)
    args.each do |a|
      begin
        Ramaze::Log.info a
      rescue
        Kernel.puts a
      end
    end
  end
  module_function :puts

  def path=(str)
    @path = str
  end
  module_function "path="

  def path
    @path || '.'
  end
  module_function :path

  def repository
    @repository ||= Repository.new(path)
  end

  ['repository'].each do |lib|
    require lib
  end

  def expand_path(npath)
    File.join(Bagpipe.path, npath)
  end
  module_function :expand_path

  def normalize_path(npath)
    expand_path(npath)
  end
  module_function :normalize_path

  def directory?(npath)
    File.directory?(npath)
  end
  module_function :directory?

  extend self
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
