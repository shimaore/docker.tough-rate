NAME := $(shell jq -r .docker_name package.json)
TAG := $(shell jq -r .version package.json)
THINKABLE_DUCKS_VERSION := $(shell jq -r '.dependencies["thinkable-ducks"]' package.json)

image: Dockerfile
	docker build -t ${NAME}:${TAG} .
	docker tag -f ${NAME}:${TAG} ${REGISTRY}/${NAME}:${TAG}

%: %.src
	sed -e 's/THINKABLE_DUCKS_VERSION/${THINKABLE_DUCKS_VERSION}/' $< >$@

tests:
	npm test

push: image tests
	docker push ${REGISTRY}/${NAME}:${TAG}
	docker push ${NAME}:${TAG}
	docker rmi ${REGISTRY}/${NAME}:${TAG}
	docker rmi ${NAME}:${TAG}
