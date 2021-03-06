
DOCKER_BUILD_FLAGS := --build-arg USER_UID=`id -u` --build-arg USER_GID=`id -g` --build-arg USER_NAME=`whoami`
DOCKER_TAG := my-docker-env
DOCKER_RUN_FLAGS := -v `pwd`:/host --user=`id -u`:`id -g` --hostname docker --rm -it

.PHONY: build run

build:
	docker build $(DOCKER_BUILD_FLAGS) -t $(DOCKER_TAG) .

run:
	docker run $(DOCKER_RUN_FLAGS) $(DOCKER_TAG)
