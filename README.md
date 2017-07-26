# theme1 環境構築  

## 実行環境  
Window7 64-bit  

## 行った作業  

### docker の install  
<http://devcenter.magellanic-clouds.com/learning/docker-toolbox.html>  
上記urlにしたがってDocker Toolboxをインストール。  

### 公開鍵の作成  
**Docker Quickstart Terminal** を起動。  
作業ディレクトリの作成＆移動  

    $ mkdir docker  
    $ cd docker  

秘密鍵の作成  
    $ ssh-keygen -f docker_centos  

### docker image の作成  
    $ cp (このディレクトリのパス)/dockerfile ./  
    $ docker build -t test_build ./  

作成したイメージの詳細についてはdockerfileを参照。  

### コンテナ作成  
    $ docker run --privileged -d -p 2222:22 -p 50050:80 -p 8888:8888 -v /c/Users/Abe/docker/Share:/share --name build test_build /sbin/init  

### MySQL の初期化等
#### 作成したコンテナにインタラクティブ操作でログイン  
    $ docker exec -it  build /bin/bash  

#### 各サービスの開始  
    $ systemctl start sshd.service  
    $ systemctl start mysqld.service  
    $ systemctl start httpd.service  

docker のインタラクティブ捜査の終了  
    $ exit  

#### ssh での接続  
    $ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root -p 2222  -i docker_centos 192.168.99.100  
ここで、IPアドレスはWindowsの場合はDocker Quickstart Terminalを起動時に初めに出てくる。  

#### MySQL の初期設定  
    $ cat /share/mysqld.log | grep password  
    $ mysql_secure_installation  

MySQL の起動確認  
    $ mysql -u root -p  
    mysql> show databases;  
    mysql> exit  

### Laravelの起動＆接続  
    $ cd /var/www/html/sample/  
    $ php artisan serve --host 0.0.0.0 --port 8888  
ホストPCで適当なブラウザで以下のIPアドレスに接続  
**192.168.99.100:8888**  
![laravel](png/laravel_homepage.PNG)  

apache HTTP server への接続  
ホストPCで適当なブラウザで以下のIPアドレスに接続  
**192.168.99.100:50050**  
![apache](png/apache_homepage.PNG)  


参考URL  
CentOS 7のDockerコンテナ内でsystemdを使ってサービスを起動する  
<http://qiita.com/yunano/items/9637ee21a71eba197345>  
CentOS で公開鍵暗号方式を使用した SSH ログイン設定  
<http://fnya.cocolog-nifty.com/blog/2012/03/centos-ssh-8291.html>  

Dockerコンテナを作成してApache2.2を動かす  
<http://qiita.com/na0AaooQ/items/31d02ae89b4501f11d5d>  
ログファイルの場所(CustomLog, ErrorLog)  
<https://www.adminweb.jp/apache/log/index1.html>  

CentOS 7 に MySQL 5.7 を yum インストールして初期設定までやってみた  
<http://enomotodev.hatenablog.com/entry/2016/09/01/225200>

CentOS7環境でLaravelを構築する  
<http://qiita.com/tosite0345/items/1e5bbeb33508abb1eaae>  
CentOS 7.0のPHPを5.4から5.6にアップグレードした  
<https://urashita.com/archives/7715>  

