IMAGE_NAME := claude-sandbox
IMAGE_TAG := latest
NAME ?= $(shell head -c4 /dev/urandom | xxd -p)
SHARED_DIR := $(CURDIR)/data/shared
INSTANCE_DIR := $(CURDIR)/data/instances/$(NAME)
HOST_CLAUDE_MD := $(HOME)/.claude/CLAUDE.md

-include .env
export

.PHONY: build run list

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

run:
	@mkdir -p $(SHARED_DIR)/go $(INSTANCE_DIR)/workspace $(INSTANCE_DIR)/claude
	@echo "Starting instance: $(NAME)"
	docker run --rm -it \
		--name claude-$(NAME) \
		$(if $(ANTHROPIC_API_KEY),-e ANTHROPIC_API_KEY,) \
		$(if $(CLAUDE_CODE_OAUTH_TOKEN),-e CLAUDE_CODE_OAUTH_TOKEN,) \
		-v $(INSTANCE_DIR)/claude:/home/claude/.claude \
		$(if $(wildcard $(HOST_CLAUDE_MD)),-v $(HOST_CLAUDE_MD):/home/claude/.claude/CLAUDE.md:ro,) \
		-v $(SHARED_DIR)/go:/home/claude/go \
		-v $(INSTANCE_DIR)/workspace:/home/claude/workspace \
		-v $$HOME/.ssh:/home/claude/.ssh:ro \
		-v $$HOME/.gitconfig:/home/claude/.gitconfig:ro \
		-v $$HOME/.config/gh:/home/claude/.config/gh:ro \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		--dangerously-skip-permissions

list:
	@docker ps --filter "name=claude-" --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}"
