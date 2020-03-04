# tumbar 

cd /Users/vjose1903/Documents/GitHub/serverRa
sudo kill -9 `cat tmp/pids/server.pid`
# subir

# bundle exec rake db:migrate
RAILS_ENV=production rake db:migrate
rails s -b 0.0.0.0 -e production
# rails s -b 0.0.0.0 -d
# bundle exec ruby bin/rails server -d -b 0.0.0.0  webrick -e production