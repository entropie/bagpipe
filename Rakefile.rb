#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "lib/bagpipe"
require "rspec/core/rake_task"

task :spec => [:run_spec] do

end


RSpec::Core::RakeTask.new(:run_spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec_*.rb')
  t.rspec_opts = %q[-f d]
  t.skip_bundler = true
  t.rcov = false
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
