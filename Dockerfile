FROM python:alpine

# Install required packages
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
apk update && \
apk add libffi-dev g++ zeromq-dev
RUN apk add openjdk11-jdk nodejs go npm yarn git
RUN pip install jupyterlab 
RUN apk add gcc cmake musl-dev zeromq make libunwind
RUN npm install -g ijavascript --unsafe-perm=true --allow-root  && \
ijsinstall --install=global 
RUN git clone https://github.com/SpencerPark/IJava.git && \
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
