ARG SINGLEUSER_BASE=quay.io/jupyterhub/singleuser:5.2.1

FROM ${SINGLEUSER_BASE} AS base
USER root

ADD conda-envs /tmp/conda-envs
ADD apt /tmp/apt

#install dependencies and other stuff that might be useful to users and turn on man pages
RUN \
    apt-get -y update && \
    xargs apt-get -y install < /tmp/apt/base.txt && \
    yes | unminimize ; exit 0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



FROM base AS with-desktop
RUN \
    conda env update -n base -f /tmp/conda-envs/desktop.yml && \
    install -d -m 0755 /etc/apt/keyrings && \
    apt-get -y update && \
    xargs apt-get -y install < /tmp/apt/desktop.txt && \
    apt-get clean && \
    dpkg --purge smplayer smplayer-l10n smplayer-themes mpv lxmusic lxpolkit deluge deluge-common deluge-gtk usermode xscreensaver xscreensaver-data xscreensaver-gl gnome-screensaver xmms2-plugin-vorbis xmms2-plugin-mad xmms2-plugin-id3v2 xmms2-plugin-alsa xmms2-core libxmmsclient6 libxmmsclient-glib1 && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R jovyan:users /home/jovyan/.cache

# cleanup the desktop, do this as a separate run statement to make it a different layer and speed up rebuilds
RUN \
    sed -i 's/1680x1050/1920x880/' /opt/conda/lib/python3.11/site-packages/jupyter_remote_desktop_proxy/setup_websockify.py

#override default menus and remove logout buttons and other unwanted features
COPY gui-config/debian-menu /etc/jwm/
COPY gui-config/system.jwmrc /etc/jwm/
COPY gui-config/xstartup /opt/conda/lib/python3.11/site-packages/jupyter_remote_desktop_proxy/share/xstartup

FROM with-desktop AS with-christmas-social
RUN \
    apt-get -y update && \
    xargs apt-get -y install < /tmp/apt/christmas-social.txt && \
    for i in `ls /usr/games | grep -v xsnow` ; do ln -s /usr/games/$i /usr/bin/$i ; done


