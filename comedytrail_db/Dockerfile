FROM mysql:8.0

LABEL maintainer="doug.ashbaugh@outlook.com"
LABEL description="MySQL 8.0 Database for ComedyTrail Application"

ENV MYSQL_ROOT_PASSWORD=comedytrail_root_secret
ENV MYSQL_DATABASE=comedytrail
ENV MYSQL_USER=comedytrail_user
ENV MYSQL_PASSWORD=comedytrail_secret

EXPOSE 3306

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD mysqladmin ping -h localhost -u ${MYSQL_USER} -p${MYSQL_PASSWORD} || exit 1
