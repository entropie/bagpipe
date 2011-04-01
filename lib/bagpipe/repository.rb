#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Bagpipe

  class Repository

    include Bagpipe

    module Playable
    end

    module Browseable

      def read(*directories)
        ret = {}
        directories.each do |dir|
          dir_contents = read_dir(expand_path(dir))
          ret[dir] = dir_contents.map{|dc| Entry.select_for(File.join(dir, dc)) }
          yield [dir, dir_contents] if block_given?
        end

        return ret.values.shift if directories.size == 1
        ret
      end

      def read_dir(dir)
        normalize_entries(Dir.entries(dir))
      end

      def normalize_entries(entries)
        entries.reject{|entry| entry =~ /^\.+/ }
      end

    end

    class Entry

      include Bagpipe

      attr_reader :path

      def initialize(spath)
        @path = spath
      end

      def self.select_for(spath)
        full_path = Bagpipe.expand_path(spath)

        spath = spath[1..-1] if spath =~ /^\//

        target =
          if Bagpipe.directory?(full_path)
            Directory
          elsif ["mp3"].include? File.extname(spath)[1..-1]
            Song
          else
            Other
          end

        target.new(spath)
      end

      def inspect
        %Q'<%-10s #{path}>'
      end
    end

    class Directory < Entry
      include Browseable

      def inspect
        super % "Directory"
      end

      def read(*directories)
        if directories.empty?
          super(*path)
        end
      end

      def entries
        read(*path)
      end
    end

    class Song < Entry
      include Playable

      def inspect
        super % "Song"
      end
    end

    class Other < Entry
      def inspect
        super % "Other"
      end
    end

    include Browseable

    attr_reader :path

    def initialize(path)
      @path = path
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
