NAME=shimaore/tough-rate

image:
	docker build -t ${NAME} .

image-no-cache:
	docker build --no-cache -t ${NAME} .

tests:
	# npm test

push: image tests
	docker push ${NAME}
