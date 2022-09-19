#!/bin/sh
docker run --rm --volumes-from jenkins -v ~/repository/volumes:/backup busybox tar cvf /backup/jenkins.tar var/lib/jenkins/
docker run --rm --volumes-from gogs    -v ~/repository/volumes:/backup busybox tar cvf /backup/gogs.tar    app/gogs
docker run --rm --volumes-from db-data -v ~/repository/volumes:/backup busybox tar cvf /backup/db-data.tar var/lib/postgresql/data