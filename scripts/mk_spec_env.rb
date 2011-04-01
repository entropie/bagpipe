#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "pp"
require "fileutils"
require "unicode"

SpecDataFile = "spec/spec_data.txt"
SpecDataDir  = "spec/spec_repos"

#options = {:noop => true, :verbose => true}
options = {:verbose => true}

File.readlines(SpecDataFile).map{|l| l.strip}.each do |line|
  begin
    dir = SpecDataDir
    if File.extname(line).empty?
      dir = File.join(SpecDataDir, line)
      FileUtils.mkdir_p(dir, options)
    else
      FileUtils.touch(File.join(dir, line), options)
    end
  rescue
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
