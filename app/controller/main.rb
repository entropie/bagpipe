#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MainController < BagpipeController

  def index(*fragments)
    fragments = ["/"] if fragments.empty?
    frags = fragments.join
    @entries = repository.read(frags)
    p Ramaze.options.get "roots"
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
