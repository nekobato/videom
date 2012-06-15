require 'sys/filesystem'

class Disk
  def self.capacity
    Conf['disk']
    stat = Sys::Filesystem.stat(Conf['disk'])
    gb = (stat.blocks_available * stat.block_size).to_f / 1024 / 1024 / 1024
    gb.to_s.scan(/^(\d+\.\d{0,3})/)[0][0].to_f
  end
end
