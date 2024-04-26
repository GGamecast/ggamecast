FROM golang:1.22.2 as builder

WORKDIR /app

COPY go.sum go.mod ./
RUN go mod download

COPY . .

ARG IMAGE_TITLE

RUN make "build/cmd/${IMAGE_TITLE}"

FROM gcr.io/distroless/static:nonroot
ARG IMAGE_TITLE
WORKDIR /app/

COPY --from=builder --chown=nonroot "/app/build/cmd/${IMAGE_TITLE}" "/app/"

ENTRYPOINT ["/app/run"]

ARG BUILD_DATE

LABEL \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.authors="Michael Miller-Hairston <Michael.MillerHairston@gmail.com>" \
    org.opencontainers.image.url="https://github.com/MMiller-Hairston" \
    org.opencontainers.image.documentation="" \
    org.opencontainers.image.source="https://github.com/MMiller-Hairston/go-starter" \
    org.opencontainers.image.version="${BUILD_VERSION}" \
    org.opencontainers.image.revision="1" \
    org.opencontainers.image.vendor="Michael Miller-Hairston" \
    org.opencontainers.image.licenses="" \
    org.opencontainers.image.ref.name="" \
    org.opencontainers.image.title="${IMAGE_TITLE}" \
    org.opencontainers.image.description="A golang application." \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.url="https://github.com/MMiller-Hairston" \
    org.label-schema.vcs-url="https://github.com/MMiller-Hairston/go-starter" \
    org.label-schema.version=$BUILD_VERSION \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor="Michael Miller-Hairston" \
    org.label-schema.name="${IMAGE_TITLE}" \
    org.label-schema.description="A golang application." \
    org.label-schema.usage=""