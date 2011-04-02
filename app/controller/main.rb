#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MainController < BagpipeController

  def index(*fragments)
    if fragments.empty?
      fragments = ["/"]
      @top = true
    else
      @top = false
    end
    frags = fragments.join
    @backlink = "/"
    @frags = frags.split("/")
    if f=@frags[0..-2]
      title = f.join
      title = "/" if title.empty?
      @bl_url = "/#{Rack::Utils.escape(f.join("/"))}"
      @bl_title = "#{title}"
    end
    @entries = repository.read(frags)
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
