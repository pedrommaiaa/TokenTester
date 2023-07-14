# Ignore instructions clashing with directory names
.PHONY: test docs book

# Include .env file and export its variables
-include .env

build:; forge build
		npx tsc --p tsconfig.json
