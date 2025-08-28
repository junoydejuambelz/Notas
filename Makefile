# Makefile for org-mode notes publishing

EMACS = emacs
PUBLISH_EL = publish.el

.PHONY: all publish clean serve

all: publish

publish:
	$(EMACS) --batch --no-init-file --load $(PUBLISH_EL) --eval "(org-publish-all t)"

clean:
	rm -rf _site/

serve: publish
	@echo "Starting simple HTTP server on port 8080..."
	@echo "Visit: http://localhost:8080"
	cd _site && python3 -m http.server 8080

help:
	@echo "Available targets:"
	@echo "  publish - Build the website from org files"
	@echo "  clean   - Remove generated files"
	@echo "  serve   - Build and serve website locally on port 8080"
	@echo "  help    - Show this help message"