# jenkins-rpi

## これは何？

Raspberry Pi4のRasbian64bitの上でJenkinsをDocker-Composeで起動させる。

## 経緯

Jenkins Blue Ocean の勉強のためRasbianにJenkinsをDockerで構築しようとしたら AMD64アーキテクチャで配布されARM64のDockerイメージがなかったようなので勉強のため構築

## 使い方

1. git clone
1. docker-compose up --build -d
1. docker exec -t jenkins-rpi /etc/init.d/jenkins start
1. http://(Raspberry PiのIPアドレス):8080/ へアクセス
1. docker exec -t jenkins-rpi cat /var/lib/jenkins/secrets/initialAdminPassword
1. ウィザードに沿ってセットアップ
1. Jenkinsの管理 > プラグインの管理 > 利用可能 > Blue Ocean を検索してインストール
1. docker exec -t jenkins-rpi sudo /etc/init.d/jenkins restart でjenkins を再起動
1. docker exec -t jenkins-rpi /usr/sbin/groupmod -g (ホストのdockerのグループID) docker
1. docker exec -t jenkins-rpi sudo /usr/sbin/usermod -aG (ホストのdockerのグループID) jenkins
1. docker exec -t jenkins-rpi id jenkins で確認
1. 現在はここまで

## 現在未完了項目

* /etc/init.d/jenkins start は自動化したい。
* リバースプロキシするために http://(IP):8080/jenkins で起動させたい。
* docker グループの変更の自動化したい。
* 現在平文なのでHTTPS化したい。
* Jenkins Blue Oceanを使えるようにしたい。
