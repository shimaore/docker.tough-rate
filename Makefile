NAME=shimaore/tough-rate
TAG=`jq -r .version package.json`

image:
	docker build -t ${NAME} .
	docker build -t ${NAME}:${TAG} .

image-no-cache:
	docker build --no-cache -t ${NAME} .
	docker build -t ${NAME}:${TAG} .

tests:
	# npm test

push: image tests
	docker push ${NAME}
	docker push ${NAME}:${TAG}
