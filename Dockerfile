FROM amd64/debian:latest
COPY slack_tar_x64 /tmp/
RUN \
	tar xzf /tmp/slack_tar_x64 -C / && \
	rm -f /tmp/slack_tar_x64
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN adduser --disabled-password --gecos "" spideroakone
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "--verbose", "--batchmode" ]
VOLUME /home/spideroakone/.config/SpiderOakONE
VOLUME /home/spideroakone/SpiderOak Hive
VOLUME /home/spideroakone/data
