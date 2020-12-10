FROM centos:centos7 as builder
RUN yum update -y && yum install -y epel-release \
        && yum install -y curl tee

ENV PATH=/root/.local/bin:${PATH}
ENV LD_LIBRARY_PATH=/root/.local/lib:${LD_LIBRARY_PATH}
RUN mkdir -p /root/.local/bin

RUN yum install -y gcc-c++ make gcc openssl-devel bzip2-devel libffi-devel \
        && curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
        && yum install -y yarn \
        && yum install -y libsqlite3x-devel.x86_64 \
        && curl -O https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz \
        && tar -xzf Python-3.8.1.tgz \
        && cd Python-3.8.1/ \
        && ./configure --prefix=${HOME}/.local/ --enable-optimizations --enable-loadable-sqlite-extensions \
        && make altinstall


FROM centos:centos7 as main
COPY --from=builder /root/.local/ /usr/local/

RUN yum update -y && yum install -y epel-release \
        && yum install -y libsqlite3x-devel.x86_64

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
        && python3.8 get-pip.py
