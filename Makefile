NAME=shimaore/tough-rate

image:
	docker build -t ${NAME} .

push: image
	docker push ${NAME}
