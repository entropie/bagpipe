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
    jfrags = fragments.join("/")
    @backlink_line = make_backlinks(*fragments)
    @entries = repository.read(jfrags)
    @bl_curl = fragments.map{|part| Rack::Utils.escape(part)}.join("/")
  end


  def play(*fragments)
    response["Content-Type"] = "audio/x-scpls"
    frags = fragments.join("/")
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
    #arr.unshift("")
    ret = []

    arr.each_with_index do |frag, ind|
      c = arr[0..arr.index(frag)]
      clas = arr.index(frag) == arr.size-1 ? " current" : ''
      ret << %Q'<a class="backlink #{clas}" href="/#{c.map{|part| Rack::Utils.escape(part) }.join("/")}">#{c.last}</a>'
    end
    ret.unshift %Q'<a class="backlink" href="/">ROOT</a>'
    ret.join("/")
  end

end


class MController < Ramaze::Controller
  map "/raw"
  engine :None
  def index(*fragments)
    response["Content-Type"] = "audio/mpeg"
    file = Bagpipe.expand_path(fragments.join("/"))
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
