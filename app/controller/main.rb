#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MainController < BagpipeController

  set_layout_except :layout => [:play, :raw]

  # FIXME: just sucks
  def index(*fragments)
    if fragments.empty?
      fragments = ["/"]
      @top = true
    else
      @top = false
    end
    frags = fragments.join
    @frags = frags.split("/")
    @backlink_line = make_backlinks(*@frags)
    @entries = repository.read(frags)
  end


  def play(*fragments)
    response["Content-Type"] = "audio/x-scpls"
    frags = fragments.join
    frags.gsub!(".pls", '')
    begin
      repository.read(frags).to_pls
    rescue Errno::ENOTDIR
      [Bagpipe::Repository::Entry.select_for(frags)].to_pls
    end
  end

  private

  def make_backlinks(*frags)
    arr = frags.dup
    arr.unshift("")
    arr.inject([]) do |m, part|
      ind = arr.index(part)
      c = arr[0..ind]
      url, desc = Rack::Utils.escape(c.join("/")[1..-1]), c.last
      url, desc = "/", "root" if desc.empty?
      m << %Q'<a class="backlink#{ind == arr.size-1 ? " current" : ""}" href="#{url}">#{desc}</a>'
    end.join("/")
  end

end


class MController < Ramaze::Controller
  map "/raw"
  engine :None
  def index(*fragments)
    response["Content-Type"] = "audio/mpeg"
    file = Bagpipe.expand_path(fragments)
    File.read(file)
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
