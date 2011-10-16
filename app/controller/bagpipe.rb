#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class BagpipeController < Ramaze::Controller

  engine :Haml

  layout(:layout) { !request.xhr? }

  include Bagpipe

  private
  def bp_render_file(arg, ohash = {})
    render_file "#{Source}/app/view/#{arg}", ohash
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
