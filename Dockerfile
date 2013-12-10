# Sequelize contribution
#
# VERSION               0.0.1

FROM ubuntu
MAINTAINER Mick Hansen <maker@mhansen.io>

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
 
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install mysql-server and provide access outside container
RUN apt-get install -y mysql-server
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# Create mysql database
RUN /usr/bin/mysqld_safe & \
    sleep 10s &&\
    echo "CREATE DATABASE sequelize_test;" | mysql

RUN echo "nohup /usr/bin/mysqld_safe &" >> /etc/bash.bashrc

# MySQL Port
EXPOSE 3306

CMD ["/usr/bin/mysqld_safe"]