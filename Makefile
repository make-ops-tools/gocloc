.PHONY: test build

build:
	mkdir -p bin
	GO111MODULE=on go build -o ./bin/gocloc cmd/gocloc/main.go

update-package:
	GO111MODULE=on go get -u github.com/hhatto/gocloc

cleanup-package:
	GO111MODULE=on go mod tidy

run-example:
	GO111MODULE=on go run examples/languages/main.go
	GO111MODULE=on go run examples/files/main.go

test:
	GO111MODULE=on go test -v

test-cover:
	GO111MODULE=on go test -v -coverprofile=coverage.out

# ==============================================================================

docker-build:
	docker build . --tag $(DOCKER_REPO)make-ops-tools/gocloc:1.0.0
	docker tag \
		$(DOCKER_REPO)make-ops-tools/gocloc:1.0.0 \
		$(DOCKER_REPO)make-ops-tools/gocloc:latest

docker-push:
	#docker push $(DOCKER_REPO)make-ops-tools/gocloc:1.0.0
	docker push $(DOCKER_REPO)make-ops-tools/gocloc:latest

# ==============================================================================

help: # List Makefile targets
	@awk 'BEGIN {FS = ":.*?# "} /^[ a-zA-Z0-9_-]+:.*? # / {printf "\033[36m%-41s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

list-variables: # List all the variables available to make
	@$(foreach v, $(sort $(.VARIABLES)),
		$(if $(filter-out default automatic, $(origin $v)),
			$(if $(and $(patsubst %_PASSWORD,,$v), $(patsubst %_PASS,,$v), $(patsubst %_KEY,,$v), $(patsubst %_SECRET,,$v)),
				$(info $v=$($v) ($(value $v)) [$(flavor $v),$(origin $v)]),
				$(info $v=****** (******) [$(flavor $v),$(origin $v)])
			)
		)
	)

.DEFAULT_GOAL := help
.EXPORT_ALL_VARIABLES:
.NOTPARALLEL:
.ONESHELL:
.PHONY: *
MAKEFLAGS := --no-print-director
SHELL := /bin/bash
ifeq (true, $(shell [[ "$(VERBOSE)" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$$ ]] && echo true))
	.SHELLFLAGS := -cex
else
	.SHELLFLAGS := -ce
endif
