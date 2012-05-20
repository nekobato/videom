
class Video
  include Mongoid::Document
  field :error_count, :type => Integer, :default => 0
  field :title, :type => String
  field :file, :type => String
  field :tags, :type => Array, :default => []
  field :url, :type => String
  field :video_url, :type => String
  field :thumb_gif, :type => String
  field :md5, :type => String
  field :exif, :type => Hash
  field :hide, :type => Boolean, :default => false
  field :skip_download, :type => Boolean, :default => false
  field :http_opt, :type => Hash, :default => {}
  field :crawl_at, :type => Integer
  field :download_at, :type => Integer
  def to_hash
    {
      :id => id,
      :title => title,
      :video_url => video_url,
      :thumb_gif => thumb_gif,
      :tags => tags,
      :url => url,
      :exif => exif
    }
  end

  def available?
    hide != true and file.to_s.size > 0 and md5.to_s.size > 0
  end

  def delete_file!
    vpath = "#{File.dirname(__FILE__)}/../#{Conf['video_dir']}/#{file}"
    File.delete vpath if File.exists? vpath
    gpath = "#{File.dirname(__FILE__)}/../#{Conf['thumb_dir']}/#{thumb_gif}"
    File.delete gpath if File.exists? gpath
    self.file = nil
    self.hide = true
    self.save
  end

  def self.find_queue_download
    self.not_in(:hide => [true]).
      where(:file => nil,
            :video_url => /^http.+/,
            :error_count.lt => Conf['retry'],
            :skip_download => false).
      asc(:error_count)
  end

  def self.find_queue_checkmd5
    self.where(:file => /.+/, :md5 => nil).desc(:_id)
  end

  def self.find_queue_checkexif
    self.not_in(:hide => [true]).
      where(:file => /.+/, :md5 => /.+/, :exif => nil)
  end

  def self.find_queue_makethumbnail
    self.not_in(:hide => [true]).
      where(:file => /.+/, :exif.exists => true,
            "$or" => [
                      {:thumb_gif.exists => false},
                      {:thumb_gif => nil}
                     ])
  end

  def self.find_availables
    not_in(:hide => [true]).
      not_in(:file => [nil]).
      where(:file.exists => true)
  end

  def self.find_by_tag(tag)
    where(:tags => /^#{tag}$/).find_availables
  end

  def self.find_by_word(word)
    self.all(:conditions =>
             {"$or" => [{:title => /#{word}/i},
                        {:tags => /#{word}/i},
                        {:url => /#{word}/i}]}).find_availables
  end

  def self.stats
    {:availables => Video.find_availables.count,
      :queue => {
        :download => Video.find_queue_download.count,
        :check_md5 => Video.find_queue_checkmd5.count,
        :check_exif => Video.find_queue_checkexif.count,
        :make_thumbnail =>Video.find_queue_makethumbnail.count
      }
    }
  end
end
