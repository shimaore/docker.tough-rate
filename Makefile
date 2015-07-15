#
# This is a generic Makefile. It uses contents from package.json
# to build Docker images.
# The package name (in package.json) MUST be `docker.<name>`, which is
# substituted (since `npm` doesn't allow slashes in names).
#
NAME=shimaore/`jq -r .name[7:] package.json`
TAG=`jq -r .version package.json`
THINKABLE_DUCKS_VERSION=`jq -r '.dependencies["thinkable-ducks"]' package.json`

image: Dockerfile
	docker build --rm=true -t ${NAME}:${TAG} .
	docker tag -f ${NAME}:${TAG} ${REGISTRY}/${NAME}:${TAG}

image-no-cache:
	docker build --rm=true --no-cache -t ${NAME}:${TAG} .

%: %.src
	sed -e "s/THINKABLE_DUCKS_VERSION/${THINKABLE_DUCKS_VERSION}/" $< >$@

tests:
	npm test

push: image tests
	# docker push ${NAME}:${TAG}
	docker push ${REGISTRY}/${NAME}:${TAG}
