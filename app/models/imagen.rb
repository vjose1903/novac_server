
require 'fileutils'
class Imagen < ApplicationRecord

      def self.saveFileInThisServer(fileName,base_64)
        _path = File.join Rails.root, 'public/img'
        # puts "#{_path}=> => =>#{fileName}"
        FileUtils.mkdir_p(_path) unless File.exist?(_path)
        File.open(File.join(_path, "#{fileName}"), 'wb') do |file|
          file.write(Base64.decode64(base_64))
          # file.puts f.read
        end
        return _path
      end

end
