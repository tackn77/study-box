#!/bin/sh
mkdir --parents ~/volumes
docker run --rm --volumes-from jenkins -v ~/volumes:/backup alpine sh -c "cd /jenkins && tar xvf /backup/jenkins.tar --strip 1"
docker run --rm --volumes-from gogs    -v ~/volumes:/backup alpine sh -c "cd /gogs    && tar xvf /backup/gogs.tar    --strip 1"
docker run --rm --volumes-from db-data -v ~/volumes:/backup alpine sh -c "cd /db-data && tar xvf /backup/db-data.tar --strip 1"
