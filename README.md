videom
======
collect videos, play on iPad


see dir

* tools - downloader

works with 

* Ruby 1.8.7
* Mac OSX or Linux
* Sinatra 1.3+
* MongoDB 2.0+


Install Dependencies
--------------------

    % gem install bundler foreman
    % bundle install


config
------

    % cp sample.config.yaml config.yml

edit config.yml.


Run
---

    % foreman start

open [http://localhost:8080](http://localhost:8080)


Deploy
------
use Passenger with "config.ru"


Console
-------

    % ruby -Ku bin/console.rb
