IMAGE_NAME=python-microservice
IMAGE_TAG=latest                      

FULL_IMAGE=gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${IMAGE_TAG}
PROJECT_ID=theta-ember-474415-r8
gcloud auth configure-docker --quiet

# build and push
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} . # or ./ (where Dockerfile is)
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}
docker push ${FULL_IMAGE}