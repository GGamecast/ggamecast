BASE_VERSION = 0.1.0
SHORT_SHA = $(shell git rev-parse --short=7 HEAD | tr -d [:punct:])
BRANCH_NAME = $(shell git rev-parse --abbrev-ref HEAD | tr -d [:punct:])
VERSION = $(BASE_VERSION)-$(SHORT_SHA)
BUILD_DATE = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
YEAR_MONTH = $(shell date -u +'%Y%m')
YEAR_MONTH_DAY = $(shell date -u +'%Y%m%d')
MAJOR_MINOR_VERSION = $(shell echo $(BASE_VERSION) | cut -d '.' -f1).$(shell echo $(BASE_VERSION) | cut -d '.' -f2)

REPOSITORY_ROOT := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_LIST))))
BUILD_DIR = $(REPOSITORY_ROOT)/build
IMAGE_BUILD_ARGS = --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg=VCS_REF=$(SHORT_SHA) --build-arg BUILD_VERSION=$(BASE_VERSION)
REGISTRY ?= ghcr.io/mmiller-hairston
TAG = $(VERSION)


CMDS = $(notdir $(wildcard cmd/*))


build/cmd: $(foreach CMD,$(CMDS),build/cmd/$(CMD)) 
$(foreach CMD,$(CMDS),build/cmd/$(CMD)): build/cmd/%: build/cmd/%/BUILD_PHONY

build/cmd/%/BUILD_PHONY:
	mkdir -p $(BUILD_DIR)/cmd/$*
	CGO_ENABLED=0 go build -v -installsuffix cgo -o $(BUILD_DIR)/cmd/$*/run ./... 

build/docker: $(foreach CMD,$(CMDS),build/docker/$(CMD)/BUILD_PHONY)
$(foreach CMD,$(CMDS),build/docker/$(CMD)): build/docker/%: build/docker/%/BUILD_PHONY:

build/docker/%/BUILD_PHONY:
	docker build \
		$(IMAGE_BUILD_ARGS) \
		--build-arg IMAGE_TITLE=$* \
		-t $(REGISTRY)/$*:$(TAG) \
		-t $(REGISTRY)/$*:$(BASE_VERSION) \
		.
