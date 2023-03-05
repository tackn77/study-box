# jenkins-rpi64

## これは何？

Raspberry Pi4のdocker-composeでJenkins/Gogsを構築する

## 経緯

Jenkins Blue Ocean の勉強のためRaspberry PiのDockerで構築しようとしたらARM64のDockerイメージがなかったようなので勉強のため構築

## 使い方

1. git clone
1. docker-compose up --build -d
1. <http://(RaspberryPiのIPアドレス):8080/> へアクセス
1. 現在はここまで

## 現在未完了項目

* リバースプロキシするために <http://(IP):8080/jenkins> で起動させたい。
* docker in docker を実現したい。
* Jenkins Blue Oceanを使えるようにしたい。
