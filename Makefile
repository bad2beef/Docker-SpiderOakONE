FETCH=wget

Docker-SpiderOakONE:
	$(FETCH) https://spideroak.com/release/spideroak/slack_tar_x64
	sudo docker build --tag bad2beef/spideroakone:latest .
