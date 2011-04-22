#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Playlist

  class Cnt
    def initialize(i = 0)
      @cnt = i
    end
    def succ
      @cnt+=1
    end
    def to_i
      @cnt
    end
  end

  # def to_player_plist_arr
  #   playlist = []
  #   sort_by{|name, url| name}.each do |entry|
  #     if entry.kind_of?(Bagpipe::Repository::Song)
  #       playlist << ["#{File.basename(entry.path)}", "#{entry.http_path}"]
  #     elsif entry.kind_of?(Bagpipe::Repository::Directory)
  #       playlist.push(*entry.read.to_player_plist_arr.sort_by{|name, url| name})
  #     end
  #   end
  #   playlist
  # end

  # class PlaylistSong < Struct.new(:name, :url, :duration)
  # end

  # def to_player_plist
  #   playlist = []
  #   to_player_plist_arr.each{|name, url|
  #     playlist << PlaylistSong.new(name, url, "02.05")
  #   }
  #   playlist
  # end

  def to_pls(j = Cnt.new, str = "[playlist]\n", init = true)
    each do |entry|
      if entry.kind_of?(Bagpipe::Repository::Song)
        str << "File#{j.succ}=#{entry.http_path}\n"
        str << "Title#{j.to_i}=#{File.basename(entry.path)}\n"
      elsif entry.kind_of?(Bagpipe::Repository::Directory)
        str << entry.read.to_pls(j, '', false)
      end
    end
    if init
      str << "\nNumberOfEntries=#{j.to_i}\n"
      str << "Version=2"
    end
    str
  end
end

# class Playlists < Hash

#   class << self
#     def playlists
#       @playlists ||= Playlists.new
#     end

#     def [](obj)
#       playlists[obj]
#     end

#     def []=(obj)
#       playlists[
#     end
#   end

#   def initialize
#     super{|h,k| h[k] = Playlists.new}
#   end
# end

class UserPlaylist

  include Playlist

  attr_reader :sid

  def initialize(sid)
    @sid = sid
  end
end

class Array
  include Playlist
end

module Bagpipe

  class Repository

    ValidSongExtensions = ["mp3", "mp4", "ogg"]

    include Bagpipe

    module Playable
    end
    module Downloadable
    end

    module Browseable

      def read(*directories)
        ret = {}
        directories.each do |dir|
          dir_contents = read_dir(expand_path(dir))
          ret[dir] = dir_contents.map{|dc| Entry.select_for(File.join(dir, dc)) }
          sort_by_type_and_name!(ret[dir])
          yield [dir, dir_contents] if block_given?
        end

        return ret.values.shift if directories.size == 1
        ret
      end

      def read_dir(dir)
        entries = normalize_entries(Dir.entries(dir))
      end

      def normalize_entries(entries)
        entries.reject{|entry| entry =~ /^\.+/ }
      end

      def sort_by_type_and_name!(entries)
        dirs, songs, rest, packs = [], [], [], []
        entries.each do |entry|
          case entry
          when Song
            songs << entry
          when Directory
            dirs << entry
          when Packed
            packs << entry
          else
            rest << entry
          end
        end
        entries.replace(dirs.sort + songs.sort + packs.sort + rest.sort)
      end

    end

    class Entry

      include Bagpipe

      attr_reader :path

      def inline_playable?
        false
      end

      def directory?
        false
      end

      def <=>(o)
        path <=> o.path
      end

      def initialize(spath)
        @path = spath
      end

      def self.select_for(spath)
        full_path = Bagpipe.expand_path(spath)

        spath = spath[1..-1] if spath =~ /^\//

        ext = File.extname(spath)[1..-1].downcase rescue ""
        target =
          if Bagpipe.directory?(full_path)
            Directory
          elsif ValidSongExtensions.include?(ext)
            Song
          elsif ["zip", "rar", "gz", "bz2"].include?(ext)
            Packed
          else
            Other
          end

        target.new(spath)
      end

      def inspect
        %Q'<%-10s #{path}>'
      end

      def link
        %Q'<a href="/%s">#{File.basename(path)}</a>'
      end

      def playable?
        true
      end
    end

    class Packed < Entry
      include Downloadable

      def playable?
        false
      end

      def inspect
        what = File.extname(path)[1..-1]
        super % "Pack(#{what})"
      end

      def csscls
        "pack"
      end

      def link
        super % ("raw/download/" + path.split("/").map{|part| Rack::Utils.escape(part)}.join("/"))
      end

      def image(width = 32, height = 32)
        %Q'<div class="pimg"><img src="/img/zip-d.png" height="#{height}" width="#{width}" /></div>'
      end
    end

    class Directory < Entry
      include Browseable

      def directory?
        true
      end

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

      def csscls
        "dir"
      end

      def link
        super % path.split("/").map{|part| Rack::Utils.escape(part)}.join("/")
      end

      def image(width = 32, height = 32)
        %Q'<div class="pimg"><img src="/img/folder-d.png" height="#{height}" width="#{width}" /></div>'
      end
    end

    class Song < Entry
      include Playable

      def inline_playable?
        File.extname(path).downcase == ".mp3"
      end

      def http_path
        url = Bagpipe.url
        url = "#{url}/" unless url[-1..-1] == "/"
        "http://#{url}raw/" + path.split("/").map{|part| Rack::Utils.escape(part)}.join("/")
      end

      def inspect
        super % "Song"
      end

      def csscls
        "song"
      end

      def image(width = 20, height = 20)
        ""
      end

      def link
        super % ("play/" + path.split("/").map{|part| Rack::Utils.escape(part)}.join("/") + ".pls")
      end
    end

    module Base64Image
      def to_data_uri
        img = File.join(Bagpipe.path, path)
        type = File.extname(img)[1..-1].downcase

        case type
        when "jpg", "jpeg", "gif", "png", "bmp"
          imgbody = [File.read(img)]
          imgbody = imgbody.pack("m").gsub("\n", '')
          return "data:#{type};base64,#{imgbody}"
        else
          false
        end
      end

      def name_or_image
        duri = to_data_uri
        if duri
          %Q'<img class="dimg" src="#{duri}" />'
        else
          File.basename(path)
        end
      end
    end

    class Other < Entry

      include Base64Image

      def inspect
        super % "Other"
      end

      def csscls
        "other"
      end

      def image(width = 20, height = 20)
        %Q'<div class="pimg" style="display:none"><img src="/img/home-d.png" height=#{height} width=#{width}/></div>'
      end

      def playable?
        false
      end

      def link
        name_or_image
      end

      def name
        link
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
