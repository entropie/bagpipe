#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MainController < BagpipeController

  set_layout_except :layout => [:play, :raw]

  # FIXME: just sucks
  def index(*fragments)
    #
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

  def playlist
    p user_sid
  end

  def player(*fragments)
    frags = fragments.join("/")
    @title = frags
    begin
      @playlist = repository.read(frags).to_player_plist
    rescue Errno::ENOTDIR
      redirect_referer
    end
  end

  private

  def user_sid
    Ramaze::Request.current.cookies["innate.sid"]
  end

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

  def download(*path)
    file = Bagpipe.expand_path(path.join("/"))
    destdir = File.join(Bagpipe::Source, "app/public/downloads")
    FileUtils.mkdir_p(destdir)
    destfile = File.join(destdir, bn = File.basename(file))
    FileUtils.ln_s(file, destfile) unless File.exist?(destfile)
    redirect "/downloads/#{Rack::Utils.escape(bn)}"
    # response["Content-Type"] = `file -I '#{file}'`.split.last
    # wrespond File.read(file)
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
