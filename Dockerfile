FROM ubuntu:14.04

RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables
    
RUN curl -sSL https://get.docker.com/ | sh

RUN echo '\"dmsetup mknodes;CGROUP=/sys/fs/cgroup;: {LOG:=stdio};[ -d $CGROUP ]||mkdir $CGROUP;mountpoint -q $CGROUP||mount -n -t tmpfs -o uid=0,gid=0,mode=0755 cgroup $CGROUP;if [ -d /sys/kernel/security ]&&! mountpoint -q /sys/kernel/security;then mount -t securityfs none /sys/kernel/security;fi;for SUBSYS in $(cut -d: -f2 /proc/1/cgroup);do [ -d $CGROUP/$SUBSYS ]||mkdir $CGROUP/$SUBSYS;mountpoint -q $CGROUP/$SUBSYS||mount -n -t cgroup -o $SUBSYS cgroup $CGROUP/$SUBSYS;echo $SUBSYS|grep -q ^name=&&{ NAME=$(echo $SUBSYS|sed s/^name=//);ln -s $SUBSYS $CGROUP/$NAME;};[ $SUBSYS = cpuacct,cpu ]&&ln -s $SUBSYS $CGROUP/cpu,cpuacct;done;pushd /proc/self/fd>/dev/null;for FD in *;do case "$FD" in [012]);;;*);eval exec "$FD>&-";;;esac;done;popd>/dev/null;rm -rf /var/run/docker.pid;if [ "$PORT" ];then exec dockerd -H 0.0.0.0:$PORT -H unix:///var/run/docker.sock $DOCKER_DAEMON_ARGS;else if [ "$LOG" == "file" ];then dockerd $DOCKER_DAEMON_ARGS&>/var/log/docker.log&;else dockerd $DOCKER_DAEMON_ARGS&;fi;((timeout = 60 + SECONDS));until docker info>/dev/null 2>&1;do if((SECONDS>= timeout));then break;fi;sleep 1;done;[[ $1 ]]&&exec "$@";exec bash --login;fi% ' > /quine/wrapdocker
ADD ./Dockerfile /quine
ADD /quine/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
RUN ["wrapdocker"]
WORKDIR /quine
RUN ["docker","build","-t","quine","."]
RUN ["docker","run","--privileged","-it","quine"]
