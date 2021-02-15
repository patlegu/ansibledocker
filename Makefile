# Fonction to import config files stored in the env directory
# define setup_env
	# $(eval ENV_FILE := env/$(1).env)
	# @echo " - setup env $(ENV_FILE)"
	# $(eval include env/$(1).env)
	# $(eval export sed 's/=.*//' env/$(1).env)
# endef

IDENT_ENV=env/ident.env
CONFIG_ENV=env/config.env
DEPLOY_ENV=env/deploy.env

# import credendtials
cnf ?= $(IDENT_ENV)
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))
# $(call setup_env,ident)

# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= $(CONFIG_ENV)
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))
# $(call setup_env,config)

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= $(DEPLOY_ENV)
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))
# $(call setup_env,deploy)

# grep the version from the mix file
VERSION=$(shell ./version.sh)


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build -t $(APP_NAME) .

build-nc: ## Build the container without caching
	docker build --no-cache -t $(APP_NAME) .

run: ## Run container on port configured in `(CONFIG_ENV)`
	docker run -i -t --rm --env-file=$(CONFIG_ENV) -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)


up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to docker Hub

# Docker publish
publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to docker Hub

publish-latest: tag-latest ## Publish the `latest` taged container to docker Hub
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to docker Hub
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# HELPERS

# generate script to login to docker HUB repo
CMD_REPOLOGIN := "cat ~/.docker/.dockerHub | /usr/bin/docker login"
ifdef DOCKER_CLI_LOGIN
CMD_REPOLOGIN += " --username $(DOCKER_CLI_LOGIN)"
endif

ifdef DOCKER_CLI_PASSWORD
CMD_REPOLOGIN += " $(DOCKER_CLI_PASSWORD)"
endif

CMD_REPOLOGOUT := "/usr/bin/docker logout"

# login to docker HUB repo-ECR
repo-login: ## Auto login to docker HUB repo
	@eval $(CMD_REPOLOGIN)

# login to docker HUB repo-ECR
repo-logout: ## Auto logout to docker HUB repo
	@eval $(CMD_REPOLOGOUT)

version: ## Output the current version
	@echo $(VERSION)
