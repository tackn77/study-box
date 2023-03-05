#!/bin/sh
docker run --rm --volumes-from jenkins -v ~/repository/volumes:/backup busybox tar cvf /backup/jenkins.tar /var/lib/jenkins_home .
docker run --rm --volumes-from gogs    -v ~/repository/volumes:/backup busybox tar cvf /backup/gogs.tar    /app/data .
docker run --rm --volumes-from db-data -v ~/repository/volumes:/backup busybox tar cvf /backup/db-data.tar /var/lib/postgresql/data .
