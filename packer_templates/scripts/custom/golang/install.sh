
#!/bin/bash
set -e
set -x

GO_VERSION=${GO_VERSION:-1.19.13}

binary=go${GO_VERSION}.linux-amd64

if [  -n "${OS_ARCH}" ] && [ "${OS_ARCH}" = "aarch" ]; then
    BINARY=go${GO_VERSION}.linux-${OS_ARCH}
fi

wget https://dl.google.com/go/${binary}.tar.gz -O /tmp/${binary}.tar.gz
tar -xvzf /tmp/${binary}.tar.gz -C /usr/lib/


cat >> ~/.bashrc << 'EOF'

export GOROOT=/usr/lib/go
export PATH=$PATH:$GOROOT/bin
export GOPROXY=https://goproxy.cn
export GO111MODULE=on
EOF