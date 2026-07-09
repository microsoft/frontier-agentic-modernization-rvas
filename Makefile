.PHONY: apm build clean

# Default target
build:
	@echo "Building _site..."
	@rm -rf _site
	@mkdir -p _site
	@# Web source (index.html + assets)
	@cp -r web/. _site/
	@# README linked from the page
	@cp README.md _site/README.md
	@# Student challenge markdown files
	@for track in java dotnet net8 customer; do \
		mkdir -p _site/Student/$$track; \
		find Student/$$track -maxdepth 1 -name "Challenge-*.md" -exec cp {} _site/Student/$$track/ \; 2>/dev/null || true; \
	done
	@# Coach solution markdown files
	@for track in java dotnet net8 customer; do \
		mkdir -p _site/Coach/$$track; \
		find Coach/$$track -maxdepth 1 -name "Solution-*.md" -exec cp {} _site/Coach/$$track/ \; 2>/dev/null || true; \
	done
	@echo "Done → _site/"

clean:
	@rm -rf _site
	@echo "Cleaned _site/"

apm:
	apm install --target copilot
