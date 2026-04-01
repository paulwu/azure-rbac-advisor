.PHONY: setup

## Creates the log/ and answers/ runtime directories required by the Azure RBAC Advisor agent.
## Run once after cloning: make setup
setup:
	mkdir -p log answers
	touch log/.gitkeep answers/.gitkeep
	@echo "✅ log/ and answers/ directories ready."
