# tumbar 

cd /home/vjose1903/proyects/servidorADM
git pull
sudo kill -9 `cat tmp/pids/server.pid`


# subir

bundle exec rake db:migrate
rails s -b 0.0.0.0 -d -e production
# rails s -b 0.0.0.0 -d
# bundle exec ruby bin/rails server -d -b 0.0.0.0  webrick -e production
# RAILS_ENV=production bin/delayed_job start