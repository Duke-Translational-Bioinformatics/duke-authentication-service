FROM centos:centos6
MAINTAINER Darin London <darin.london@duke.edu>

RUN ["/usr/bin/yum", "clean", "all"]
RUN ["/usr/bin/yum", "distro-sync", "-q", "-y", "--nogpgcheck"]
RUN ["/usr/bin/yum", "update", "-q", "-y","--nogpgcheck"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "gcc","gcc-c++", "glibc-static", "which", "zlib-devel", "readline-devel", "libcurl-devel", "tar"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "openssl", "openssl-devel"]
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "unzip", "bzip2", "wget"]
#shellshocked!
RUN ["/usr/bin/yum", "update", "-y", "--nogpgcheck", "bash"]
RUN ["mkdir", "-p", "/root/installs"]
WORKDIR /root/installs
ADD install_epel.sh /root/installs/install_epel.sh
RUN ["chmod", "u+x", "/root/installs/install_epel.sh"]
RUN ["/root/installs/install_epel.sh"]

# Apache and ssl
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "httpd", "httpd-devel", "apr-devel", "apr-util-devel", "mod_ssl"]
ADD ssl.conf /etc/httpd/conf.d/ssl.conf

# shibboleth
ADD duke-el-shib2.repo /etc/yum.repos.d/duke-el-shib2.repo
RUN ["/usr/bin/yum", "install", "-y", "--nogpgcheck", "shibboleth"]
ADD shib.conf /etc/httpd/conf.d/shib.conf

ADD reverse_proxy.conf /etc/httpd/conf.d/reverse_proxy.conf
ADD run.sh /usr/local/bin/run.sh
RUN ["chmod", "u+x", "/usr/local/bin/run.sh"]
EXPOSE 443
CMD ["/usr/local/bin/run.sh"]
