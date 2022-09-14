FROM nginx:1.23

# RUN apt-get update -qq && apt-get install -y systemd

RUN rm /etc/nginx/conf.d/*
COPY default.conf /etc/nginx/conf.d/default.conf


# RUN mkdir -p /var/www/your_domain/html
# RUN chown -R $USER:$USER /var/www/your_domain/html
# RUN chmod -R 755 /var/www/your_domain
# COPY your_domain /etc/nginx/sites-available/your_domain
# RUN mkdir /etc/nginx/sites-enabled
# RUN ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/

# COPY novac_proxy /etc/nginx/sites-available/novac_proxy
# # RUN mkdir /etc/nginx/sites-enabled
# RUN ln -s /etc/nginx/sites-available/novac_proxy /etc/nginx/sites-enabled/

# RUN service nginx restart