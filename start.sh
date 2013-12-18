POSTGRES_DATA=/var/lib/postgresql/9.1/main
POSTGRES_BIN=/usr/lib/postgresql/9.1/bin
POSTGRES_CONFIG=/etc/postgresql/9.1/main/postgresql.conf

#### DONT EVER PUT & (BG PROCESS) BEHIND THE LAST CALL
/usr/bin/mysqld_safe &
su postgres -c "$POSTGRES_BIN/postgres -D $POSTGRES_DATA -c config_file=$POSTGRES_CONFIG"