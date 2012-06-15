web: bundle exec rackup config.ru -p $PORT -s thin
crawl: bundle exec ruby tools/crawl.rb -loop -interval 600
download: bundle exec ruby tools/download.rb -loop -interval 30
md5: bundle exec ruby tools/check_md5.rb -loop -interval 30
exif: bundle exec ruby tools/check_exif.rb -loop -interval 30
thumb: bundle exec ruby tools/make_thumbnails.rb -loop -interval 30
