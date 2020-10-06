FROM marketplace.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext \
    && apt-get clean

ADD manifest/ /tmp/manifest/

ADD test/ /tmp/test/manifest/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ADD test/schema.yaml /tmp/test/schema.yaml
RUN cat /tmp/test/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/test/schema.yaml.new \
    && mv /tmp/test/schema.yaml.new /tmp/test/schema.yaml
RUN ls /tmp

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_envsubst:0.10.7
COPY --from=build /tmp/manifest /data/manifest/
COPY --from=build /tmp/test/manifest /data-test/manifest/
COPY --from=build /tmp/test/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1800
ENV TESTER_TIMEOUT 1800