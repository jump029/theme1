FROM centos:centos7

# SSHで接続可能にする
# OpenSSH サーバをインストール
RUN yum -y install openssh-server

# root でログインできるようにする
RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
# 鍵認証で接続可能にに
RUN sed -ri 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# 鍵認証のみ接続可能に
RUN sed -ri 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# root のパスワードを 'root' にする
RUN echo 'root:root' | chpasswd

# sshd のサービスが自動で起動するように
RUN systemctl enable sshd

# 鍵の登録
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
# 鍵のコピー
ADD docker_centos.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# apache のインストール
RUN yum -y install httpd
# ServerName の変更
RUN sed -i -e 's/\#ServerName www.example.com:80/ServerName example-web-server.example.com/g' /etc/httpd/conf/httpd.conf
# access log を共有ディレクトリ(/share)に出力するように
RUN sed -i -e 's/CustomLog "logs\/access_log" combined/CustomLog "\/share\/access_log" combined/g' /etc/httpd/conf/httpd.conf
# error log を共有ディレクトリ(/share)に出力するように
RUN sed -i -e 's/ErrorLog "logs\/error_log"/ErrorLog "\/share\/error_log"/g' /etc/httpd/conf/httpd.conf
RUN systemctl enable httpd.service

# mysql のインストール
# MySQLのyumリポジトリを追加
RUN rpm -ivh http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
# MySQL をインストール
#RUN yum -y install mysql-community-server
RUN yum -y --nogpgcheck install mysql-community-server
# MySQL のlogを共有ディレクトリ(/share)に出力するように
RUN sed -i -e 's/log-error=\/var\/log\/mysqld.log/log-error=\/share\/mysqld.log/g' /etc/my.cnf
# デフォルトの文字コードをUTF-8に
RUN echo "character-set-server = utf8" >> /etc/my.cnf
RUN systemctl enable mysqld.service

# laravel のインストール
# php5.6 をインストール(centos7のdefaultは5.4だが5.5.9以上が必要なため)
# wget をインストール
RUN yum -y install wget
# epel をインストール
RUN yum -y install epel-release
# remi をインストール
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN rpm -Uvh remi-release-7.rpm
# php56 のenabled=0だけを書き換えたかったので行数を指定して入れ替えている
RUN sed -i -e '24,33s/enabled=0/enabled=1/g' /etc/yum.repos.d/remi.repo
RUN yum upgrade php php-common
RUN yum -y install --enablerepo=remi --enablerepo=remi-php56 php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-xml
# Composer のインストール (yumで入るようだがなぜかできなかったのでネットから落としてくる)
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
# laravel のインストール
RUN composer global require "laravel/installer=~1.1"
RUN composer create-project laravel/laravel /var/www/html/sample --prefer-dist
RUN chmod 777 /var/www/html/sample

CMD ["/sbin/init"]

