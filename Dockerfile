# Copyright 2017-2019 Intel Corporation and OPNFV. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM centos:7
RUN yum update -y && \
        yum install -y which sudo git && \
        yum clean all && \
        git config --global http.sslVerify false && \
        yum -y install flex bison autoconf automake libtool make

ENV DOCKER y
ENV WITH_DPDK n
ENV COLLECTD_FLAVOR stable
ENV repos_dir /collectd

WORKDIR ${repos_dir}
RUN git clone https://github.com/collectd/collectd.git 

RUN cd collectd && \
sh ./build.sh && ./configure &&\
        useradd -ms /bin/bash collectd_exec && \
        echo "collectd_exec ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
        make install
       
# Remove default plugin configureation directory, to create our own        
RUN rm -rf /opt/collectd/etc/collectd.conf.d        

COPY launcher.py /launcher.py
RUN chmod +x /launcher.py

ENTRYPOINT ["/launcher.py"]
