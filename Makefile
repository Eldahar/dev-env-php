REGISTRY_URL=eldahar/dev-env-php
BUILD_NUMBER ?= 999

build:
	docker build -t ${REGISTRY_URL}:${BUILD_NUMBER} .

push:
	docker push ${REGISTRY_URL}:${BUILD_NUMBER}
	docker tag ${REGISTRY_URL}:${BUILD_NUMBER} ${REGISTRY_URL}:latest
	docker push ${REGISTRY_URL}:latest
