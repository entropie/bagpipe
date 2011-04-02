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
    if f=@frags[0..-2]
      title = @frags.join("/")
      title = "/" if title.empty?
      @bl_url = "/#{Rack::Utils.escape(f.join("/"))}"
      @bl_curl = Rack::Utils.escape(@frags.join("/"))
      @bl_title = "#{title}"
    end
    @entries = repository.read(frags)
  end


  def play(*fragments)
    response["Content-Type"] = "audio/x-scpls"
    frags = fragments.join
    frags.gsub!(".pls", '')
    repository.read(frags).to_pls
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
