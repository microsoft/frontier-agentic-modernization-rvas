.PHONY: apm build clean skills-docs test

# Default target
build:
	@python3 scripts/supporting-skills.py --check
	@echo "Building _site..."
	@rm -rf _site
	@mkdir -p _site
	@# Web source (index.html + assets)
	@cp -r web/. _site/
	@# README linked from the page
	@cp README.md _site/README.md
	@# Student challenges and route setup guides
	@for track in java dotnet net8 customer rebuild; do \
		mkdir -p _site/Student/$$track; \
		find Student/$$track -maxdepth 1 -name "*.md" -exec cp {} _site/Student/$$track/ \; 2>/dev/null || true; \
	done
	@cp Student/sample-architecture.md _site/Student/sample-architecture.md
	@# Coach solutions, facilitation guides, and rubrics
	@for track in java dotnet net8 customer rebuild; do \
		mkdir -p _site/Coach/$$track; \
		find Coach/$$track -maxdepth 1 -name "*.md" -exec cp {} _site/Coach/$$track/ \; 2>/dev/null || true; \
	done
	@cp CONTRIBUTING.md _site/CONTRIBUTING.md
	@cp Coach/README.md _site/Coach/README.md
	@find plugins -type f -name "*.md" -exec cp --parents {} _site/ \;
	@# Shared coach troubleshooting guide, linked from every Coach Solution-*.md
	@cp Coach/TROUBLESHOOTING.md _site/Coach/TROUBLESHOOTING.md
	@# Presenter demo guides opened in the site's shared markdown drawer
	@for track in java dotnet; do \
		mkdir -p _site/Coach/demo/$$track; \
		cp Coach/demo/$$track/guide.md _site/Coach/demo/$$track/guide.md; \
	done
	@# Infra deployment README files (and referenced images) linked from the Challenge-00 docs
	@for track in java dotnet; do \
		mkdir -p _site/Student/Resources/$$track/infra; \
		cp Student/Resources/$$track/infra/README.md _site/Student/Resources/$$track/infra/ 2>/dev/null || true; \
		cp -r Student/Resources/$$track/infra/assets _site/Student/Resources/$$track/infra/ 2>/dev/null || true; \
	done
	@echo "Done → _site/"

clean:
	@rm -rf _site
	@echo "Cleaned _site/"

apm:
	apm install --target copilot

skills-docs:
	python3 scripts/supporting-skills.py

test:
	python3 -B -m unittest discover -s scripts -p 'test_*.py'
	node --test scripts/test-site.cjs
	python3 -B -m unittest discover -s plugins/agentic-modernization/skills/cloud-architecture-diagram/tests
