# Use Amazon Linux 2 base image
FROM amazonlinux:2

# Install Apache (httpd)
RUN yum update -y && \
    yum install -y httpd && \
    yum clean all

# Copy application files to Apache document root
COPY ./dist/ /var/www/html/

# Set correct permissions for Apache user
RUN chown -R apache:apache /var/www/html/

# Expose port 80
EXPOSE 80

# Run Apache in the foreground (Amazon Linux uses httpd, not apache2ctl)
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
