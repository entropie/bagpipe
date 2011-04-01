#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "find"
require "fileutils"

Target = File.expand_path(ARGV.shift || "~/Music/local")

File.open("spec/spec_data.txt", 'w+') do |fp|
  Find.find(Target) do |file|
    Find.prune if file =~ /\.DS_Store/
    nfile = file.gsub(Target, '')[1..-1]
    fp.puts nfile if nfile
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
