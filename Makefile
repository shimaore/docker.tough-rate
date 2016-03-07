#
# This is a generic Makefile. It uses contents from package.json
# to build Docker images.
# The package name (in package.json) MUST be `docker.<name>`, which is
# substituted (since `npm` doesn't allow slashes in names).
#
NAME=`jq -r .docker_name package.json`
TAG=`jq -r .version package.json`
THINKABLE_DUCKS_VERSION=`jq -r '.dependencies["thinkable-ducks"]' package.json`

image: Dockerfile
	docker build -t ${NAME}:${TAG} .
	docker tag -f ${NAME}:${TAG} ${REGISTRY}/${NAME}:${TAG}

%: %.src
	sed -e "s/THINKABLE_DUCKS_VERSION/${THINKABLE_DUCKS_VERSION}/" $< >$@

tests:
	npm test

push: image tests
	docker push ${REGISTRY}/${NAME}:${TAG}
	docker push ${NAME}:${TAG}
	docker rmi ${REGISTRY}/${NAME}:${TAG}
	docker rmi ${NAME}:${TAG}
