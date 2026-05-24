.PHONY: up build down scale-ubuntu logs

# Default number of Ubuntu nodes if not specified
NODES ?= 3

# Start the lab in the background
up:
	docker compose up -d

# Build the custom Rundeck image and start the lab
build:
	docker compose up -d --build

# Tear down the lab and clean up networking
down:
	docker compose down

# Scale the Ubuntu target nodes (usage: make scale-ubuntu NODES=5)
scale-ubuntu:
	docker compose up -d --scale target-ubuntu=$(NODES)

# Watch the logs for the Rundeck container
logs:
	docker compose logs -f rundeck