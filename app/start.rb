#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"
$: << "../../innate/lib"
require "../../ramaze/lib/ramaze.rb"


begin
  require "../lib/bagpipe"
rescue LoadError
  require "bagpipe"
end

# Dir["#{Bagpipe::Source}/lib/oy/middleware/*.rb"].each do |mw|
#   require mw
# end

controller = %w"bagpipe main css".map{ |lib|
  File.join("controller", lib)
}
libs = []

(controller + libs).each{|lib| require lib}


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
