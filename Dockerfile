FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:jonathonf/vim

RUN apt-get install -y \
    curl \
    git \
    vim

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.3/bin/linux/amd64/kubectl && \
    chmod a+rx kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN curl -LO https://github.com/derailed/k9s/releases/download/$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/k9s_Linux_x86_64.tar.gz && \
    tar xvf k9s_Linux_x86_64.tar.gz && \
    chmod a+rx ./k9s && \
    mv ./k9s /usr/local/bin/k9s && \
    rm k9s_Linux_x86_64.tar.gz

RUN curl -s https://raw.githubusercontent.com/thmhoag/dotfiles/master/scripts/dotfiles-clone.sh | bash
