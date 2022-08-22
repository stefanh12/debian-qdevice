FROM debian:bullseye
RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections
RUN apt-get update
RUN apt-get dist-upgrade -qy
RUN apt-get install -qy --no-install-recommends systemd systemd-sysv corosync-qnetd  openssh-server 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /var/log/alternatives.log /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


ENV UMASK=000
ENV UID=99
ENV GID=100
ENV ROOT_PWD="Docker!"

RUN echo "root:${ROOT_PWD}" | chpasswd
RUN export ROOT_PWD="secret"
#RUN echo 'root:password' | chpasswd
RUN chmod -R 770 /etc/corosync/
RUN chown -R ${UID}:${GID} /etc/corosync/
RUN chown -R coroqnetd:coroqnetd /etc/corosync/
RUN systemctl mask -- dev-hugepages.mount sys-fs-fuse-connections.mount
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id

FROM debian:bullseye
COPY --from=0 / /
ENV container docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]
CMD [ "/sbin/init" ]