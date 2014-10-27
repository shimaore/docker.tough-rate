NAME=shimaore/tough-rate

all:
	docker build -t ${NAME} .

push:
	docker push ${NAME}
