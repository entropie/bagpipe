#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe Bagpipe::Repository do

  Repos = Bagpipe.repository
  context "Path" do
    it "should have a path" do
      Repos.path.should == "spec/spec_repos"
    end
  end

  context "Database" do
    it "should be possible to read /" do
      #pp Repos.read("/").last.read #, "streets - cyberspace and reds deluxe editio",

      # puts
      pp Repos.read("/")
      # puts
      pp Repos.read("Joint Venture").last.read
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
