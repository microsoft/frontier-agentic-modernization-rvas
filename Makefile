.PHONY: apm build check-links check-links-external clean skills-docs test

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
	@mkdir -p _site/labs
	@# Labs (lab.yaml): every lab-level Markdown file plus its modules
	@for lab in $$(find labs -mindepth 2 -maxdepth 2 -name lab.yaml -not -path 'labs/_*' -printf '%h\n'); do \
		mkdir -p _site/$$lab/challenges; \
		cp $$lab/*.md _site/$$lab/; \
		cp $$lab/challenges/*.md _site/$$lab/challenges/; \
	done
	@cp CONTRIBUTING.md _site/CONTRIBUTING.md
	@cp labs/README.md _site/labs/README.md
	@find plugins -type f -name "*.md" -exec cp --parents {} _site/ \;
	@# Shared troubleshooting guide, linked from every lab module
	@cp labs/TROUBLESHOOTING.md _site/labs/TROUBLESHOOTING.md
	@# Presenter demo guides opened in the site's shared markdown drawer
	@for track in java dotnet; do \
		mkdir -p _site/demo/$$track; \
		cp demo/$$track/guide.md _site/demo/$$track/guide.md; \
	done
	@# Infra deployment README files (and referenced images) linked from the Module-00 docs
	@for track in 01-java 02-dotnet; do \
		mkdir -p _site/labs/$$track/resources/infra; \
		cp labs/$$track/resources/infra/README.md _site/labs/$$track/resources/infra/ 2>/dev/null || true; \
		cp -r labs/$$track/resources/infra/assets _site/labs/$$track/resources/infra/ 2>/dev/null || true; \
	done
	@echo "Done → _site/"

clean:
	@rm -rf _site
	@echo "Cleaned _site/"

apm:
	apm install --target copilot

skills-docs:
	python3 scripts/supporting-skills.py

check-links:
	python3 scripts/check_links.py

check-links-external:
	python3 scripts/check_links.py --external

test:
	labs/_framework/labs.py validate
	python3 scripts/check_links.py
	python3 -B -m unittest discover -s scripts -p 'test_*.py'
	node --test scripts/test-site.cjs
	python3 -B -m unittest discover -s plugins/agentic-modernization/skills/cloud-architecture-diagram/tests
