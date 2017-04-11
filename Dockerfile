FROM ubuntu:16.10

ENV TZ=Europe/Prague

RUN apt-get update \
    && apt-get install -y software-properties-common wget git curl graphviz openjdk-8-jre libxext-dev libxrender-dev libxtst-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN mkdir /root/projects \
    && mkdir /root/.PhpStorm2017.1 \
    && touch /root/.PhpStorm2017.1/.keep

RUN mkdir /opt/phpstorm && wget -O - https://download.jetbrains.com/webide/PhpStorm-2017.1.tar.gz | tar xzf - --strip-components=1 -C "/opt/phpstorm"

COPY keys/id_rsa.pub /root/.ssh/authorized_keys

RUN apt-get update && apt-get install -y openssh-server supervisor wget vim nano \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "export VISIBLE=now" >> /etc/profile \
    && echo "PS1='\[\033[0;33m\](collabim-phpstorm) \w\[\033[0m\]\[\033[37m\]$ \[\033[0m\]'\n" >> /root/.bash_profile \
    && echo "Compression yes" >> /etc/ssh/sshd_config \
    && echo "Ciphers blowfish-cbc,arcfour" >> /etc/ssh/sshd_config \
    && echo "X11Forwarding yes" >> /etc/ssh/sshd_config \
    && echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config \
    && echo "X11UseLocalhost yes" >> /etc/ssh/sshd_config

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord"]
