FROM wnameless/oracle-xe-11g:latest
MAINTAINER Darin London <darin.london@duke.edu>

ADD provision.sh /usr/sbin/provision.sh
RUN ["chmod", "+x", "/usr/sbin/provision.sh"]
ADD provision.sql /root/provision.sql
CMD /usr/sbin/provision.sh && /usr/sbin/sshd -D
