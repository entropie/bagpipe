#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

require "rack/utils"

describe Bagpipe::Repository do

  Repos = Bagpipe.repository

  context "Path" do
    it "should have a path" do
      Repos.path.should == "spec/spec_repos"
    end
  end

  context "Entry" do
    it "should select the right class for a song" do
      Repository::Entry.select_for("/a/b/c.mp3").class.should == Repository::Song
      Repository::Entry.select_for("/a/b/c.mp4").class.should == Repository::Song
      Repository::Entry.select_for("/a/b/c.ogg").class.should == Repository::Song
    end

    it "should select the right class for foo" do
      Repository::Entry.select_for("/a/b/c.other").class.should == Repository::Other
    end

    it "should select the right class for a directory" do
      Repository::Entry.select_for("Joint Venture").class.should == Repository::Directory
    end
  end

  context "Database" do
    it "should be possible to read /" do
      contents = Repos.read("/")
      contents.all?{|r| r.kind_of?(Repository::Entry) }.should == true
      contents.size.should >= 19
    end

    it "should be possible to read a subdirectory" do
      contents = Repos.read("Bodo Wartke")
      contents.all?{|r| r.kind_of?(Repository::Directory)}.should == true
    end

    it "should be possible to do rereads for directories" do
      contents = Repos.read("Joint Venture")
      contents.each do |cont|
        ncont = cont.read
        ncont.size.should >= 4
        ncont.all?{|r| r.kind_of?(Repository::Directory)}.should == false
        ncont.all?{|r| r.kind_of?(Repository::Song) or r.kind_of?(Repository::Other)}.should == true
      end
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
