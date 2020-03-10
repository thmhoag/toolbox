FROM ubuntu:18.04 as base

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:jonathonf/vim

RUN apt-get install -y \
    curl \
    git \
    vim \
    libevent-dev \
    nodejs npm \
    sudo

# tmux installer layer
FROM base as tmux

RUN apt-get install -y \
    git automake build-essential pkg-config \
    libevent-dev libncurses5-dev curl

RUN curl -LO https://raw.githubusercontent.com/thmhoag/dotfiles/master/scripts/install/tmux.sh && \
    chmod a+rx ./tmux.sh && \
    ./tmux.sh

# k9s installer layer
FROM base as k9s

WORKDIR /app
RUN curl -LO https://github.com/derailed/k9s/releases/download/$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/k9s_Linux_x86_64.tar.gz && \
    tar xvf k9s_Linux_x86_64.tar.gz && \
    chmod a+rx ./k9s

# kubectl installer layer
FROM base as kubectl

WORKDIR /app
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.3/bin/linux/amd64/kubectl && \
    chmod a+rx kubectl

# final image layer
FROM base as final

WORKDIR /root

COPY --from=kubectl /app/kubectl /usr/local/bin/kubectl
COPY --from=k9s /app/k9s /usr/local/bin/k9s
COPY --from=tmux /usr/local/bin/tmux /usr/local/bin/tmux

RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

RUN curl -s https://raw.githubusercontent.com/thmhoag/dotfiles/master/scripts/dotfiles-clone.sh | bash

RUN ln -s -f /bin/bash /bin/sh
RUN tmux start-server && \
    tmux new-session -d && \
    sleep 1 && \
    /root/.tmux/plugins/tpm/scripts/install_plugins.sh && \
    tmux kill-server

COPY .vimrc.pluginstall .
RUN vim -E -s -u ".vimrc.pluginstall" +'PlugInstall --sync' +qa

RUN git clone https://github.com/yuya-takeyama/helmenv.git $HOME/.helmenv && \
    ln -snf $HOME/.helmenv/bin/helm /usr/local/bin/helm && \
    ln -snf $HOME/.helmenv/bin/helmenv /usr/local/bin/helmenv && \
    ln -snf $HOME/.helmenv/bin/tiller /usr/local/bin/tiller

SHELL ["/bin/bash", "-c"]
RUN helmenv install 3.1.1 && \
    helmenv global 3.1.1