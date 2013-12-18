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

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# MySQL
	# Install
	RUN apt-get install -y mysql-server
	# Config (allow remote connections)
	RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

	# Create database & user
	RUN /usr/bin/mysqld_safe & \
	    sleep 10s &&\
	    echo "CREATE DATABASE sequelize_test;" | mysql &&\
	    echo "GRANT ALL ON sequelize_test.* TO sequelize_test@'%' IDENTIFIED BY ''; FLUSH PRIVILEGES" | mysql

# PostgreSQL

	# Install
	RUN apt-get install -y postgresql postgresql-contrib

	# Config files
	ADD postgresql/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
	ADD postgresql/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf

	# Env
	ENV POSTGRES_DATA /var/lib/postgresql/9.1/main
	ENV POSTGRES_BIN /usr/lib/postgresql/9.1/bin
	ENV POSTGRES_CONFIG /etc/postgresql/9.1/main/postgresql.conf

	# Some setup
	RUN rm -rf $POSTGRES_DATA
	RUN mkdir -p $POSTGRES_DATA
	RUN chown -R postgres $POSTGRES_DATA
	RUN su postgres sh -c "$POSTGRES_BIN/initdb $POSTGRES_DATA"

	# Create database & user
	RUN echo "CREATE USER sequelize_test WITH SUPERUSER PASSWORD '';" | \
	    su postgres sh -c "$POSTGRES_BIN/postgres --single \
	    -D $POSTGRES_DATA \
	    -c config_file=$POSTGRES_CONFIG"

	RUN echo "CREATE DATABASE sequelize_test WITH OWNER sequelize_test;" | \
	    su postgres sh -c "$POSTGRES_BIN/postgres --single \
	    -D $POSTGRES_DATA \
	    -c config_file=$POSTGRES_CONFIG"

	# HSTORE
	RUN echo "CREATE EXTENSION hstore;" | \
	    su postgres sh -c "$POSTGRES_BIN/postgres --single \
	    -D $POSTGRES_DATA \
	    -c config_file=$POSTGRES_CONFIG"

# Ports
	EXPOSE 3306
	EXPOSE 5432

ADD start.sh /usr/bin/sequelize.sh
RUN chmod +x /usr/bin/sequelize.sh
RUN echo "/usr/bin/sequelize.sh" >> /etc/bash.bashrc
CMD ["/bin/bash"]