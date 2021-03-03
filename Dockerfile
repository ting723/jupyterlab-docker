FROM python:alpine

# Install required packages
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
apk update && \
apk add libffi-dev g++  zeromq zeromq-dev cmake musl-dev make libunwind && \
apk add openjdk11-jdk nodejs go npm yarn git
RUN pip install jupyterlab 
RUN pip install pyzmq
RUN git clone https://gitee.com/ting723/IJava.git && \
cd IJava/ && \
./gradlew installKernel && \
cd .. && rm -rf IJava && \
apk del git 
RUN echo "export GOPROXY=https://goproxy.cn" >> ~/.profile && source ~/.profile
RUN env GO111MODULE=on go get github.com/gopherdata/gophernotes && \
mkdir -p ~/.local/share/jupyter/kernels/gophernotes && \
cd ~/.local/share/jupyter/kernels/gophernotes && \
cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v0.7.1/kernel/*  "."  && \
chmod +w ./kernel.json  && \
sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < kernel.json.in > kernel.json

ENV LANG=C.UTF-8

EXPOSE 8888
RUN mkdir -p /opt/app/data
CMD jupyter lab --ip=* --port=8888 --no-browser --notebook-dir=/opt/app/data --allow-root
