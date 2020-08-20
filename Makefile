SRV_NAME := "py-httpd"
ID_IMG := $(shell docker images -q ${SRV_NAME})
ID_DOC_RUNNING := $(shell docker ps -q -f name=${SRV_NAME})
ID_DOC_STOPPED := $(shell docker ps -q -f name=${SRV_NAME} -f status=exited)


.PHONY: build
build: ## Build Image
ifeq ($(ID_IMG),)
	@echo Build Image
	@docker build -t ${SRV_NAME} .
else
	@echo Image exists: ${ID_IMG}
endif


.PHONY: destroy
destroy: ## Stop and remove container, image
ifneq ($(ID_IMG),)
	@$(MAKE) -s rmi
endif


.PHONY: run
run: ## Create image, start container
ifeq ($(ID_IMG),)
	@$(MAKE) -s build
endif
ifeq ($(ID_DOC_STOPPED),)
	@echo Create and run the container
	@docker run -d -p 65080:80 --name ${SRV_NAME} ${SRV_NAME}
else
ifeq ($(ID_DOC_RUNNING),)
	@echo Container exists: ${ID_DOC_STOPPED}
	@$(MAKE) -s start
endif
endif


.PHONY: rm
rm: ## Remove the container
ifneq ($(ID_DOC_RUNNING),)
	@$(MAKE) -s stop rm
endif
ifneq ($(ID_DOC_STOPPED),)
	@echo Remove the container
	@docker rm ${SRV_NAME}
endif


.PHONY: rmi
rmi: ## Remove the image
ifneq ($(ID_IMG),)
ifneq ($(ID_DOC_RUNNING),)
	@$(MAKE) -s rm
endif
ifneq ($(ID_DOC_STOPPED),)
	@$(MAKE) -s rm
endif
	@echo Remove the image
	@docker rmi ${SRV_NAME}
endif


.PHONY: start
start: ## Start the container
ifeq ($(ID_DOC_RUNNING),)
ifneq ($(ID_DOC_STOPPED),)
	@echo Start the container
	@docker start ${SRV_NAME}
else
	@echo Container was not created, 'make run' instead
endif
endif


.PHONY: status
status: ## Show project status
ifneq ($(ID_IMG),)
	@echo ${SRV_NAME} image created: ${ID_IMG}
else
	@echo ${SRV_NAME} image not created
endif
ifneq ($(ID_DOC_STOPPED),)
	@echo ${SRV_NAME} ${ID_DOC_STOPPED} is down
endif
ifneq ($(ID_DOC_RUNNING),)
	@echo ${SRV_NAME} ${ID_DOC_RUNNING} is up and running
endif


.PHONY: stop
stop: ## Stop the container
ifneq ($(ID_DOC_RUNNING),)
	@echo Stop the container
	@docker stop ${SRV_NAME}
endif


.PHONY: help
help: ## Show usage help
	@echo "Valid targets for $(PROJECT):"
	@grep -E '^[a-zA-Z_-]+:.?*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
