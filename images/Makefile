build:
	docker build -t supercollider-radio .

run:
	docker run -d -p 8000:8000 --cap-add=SYS_NICE --cap-add=SYS_RESOURCE --device /dev/snd --name supercollider-radio supercollider-radio

stop:
	docker stop supercollider-radio && docker rm supercollider-radio

logs:
	docker logs -f supercollider-radio

restart: stop run
