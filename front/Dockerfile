# cinema_backend_final_1-main/nginx/Dockerfile
FROM nginx:alpine

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy your custom Nginx config
COPY ./nginx/nginx.conf /etc/nginx/conf.d/nginx.conf

# Copy frontend static files (HTML, CSS, JS, images, etc.)
# Assuming your frontend files are directly in the cinema_backend_final_1-main directory
COPY ./index.html /usr/share/nginx/html/frontend/index.html
COPY ./details.html /usr/share/nginx/html/frontend/details.html
COPY ./lk.html /usr/share/nginx/html/frontend/lk.html
COPY ./lk.js /usr/share/nginx/html/frontend/lk.js
COPY ./script.js /usr/share/nginx/html/frontend/script.js
COPY ./details.js /usr/share/nginx/html/frontend/details.js

COPY ./css /usr/share/nginx/html/frontend/css
COPY ./photo /usr/share/nginx/html/frontend/photo
