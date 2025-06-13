SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: format check test

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: help
help:
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format
format: ## Format the code
	@dart format -l 120 lib/ test/
	@dart fix --apply .

.PHONY: get
get: ## Get the dependencies
	@dart pub get

.PHONY: outdated
outdated: get ## Check for outdated dependencies
	@dart pub outdated --show-all --dev-dependencies --dependency-overrides --transitive --no-prereleases

.PHONY: codegen
codegen: get ## Generate the code
	@dart run build_runner build --delete-conflicting-outputs

.PHONY: gen
gen: codegen

.PHONY: test
test: get ## Run the tests
	@dart test --debug --coverage=coverage --platform vm test/unit_test.dart

.PHONY: coverage
coverage: get ## Generate the coverage report
	@dart pub global activate coverage
	@dart pub global run coverage:test_with_coverage -fb -o coverage -- \
		--platform=vm --compiler=kernel --coverage=coverage \
		--reporter=expanded --file-reporter=json:coverage/tests.json \
		--timeout=10m --concurrency=12 --color \
			test/unit_test.dart
	@lcov --list coverage/lcov.info
	@genhtml -o coverage coverage/lcov.info

.PHONY: analyze
analyze: get ## Analyze the code
	@dart format --set-exit-if-changed -l 120 -o none lib/ test/
	@dart analyze --fatal-infos --fatal-warnings lib/ test/

.PHONY: check
check: analyze publish-check ## Check the code
	@dart pub global activate pana
	@pana --json --no-warning --line-length 120 > log.pana.json

.PHONY: pana
pana: check

.PHONY: dart-version
dart-version: ## Show the Dart version
	@dart --version
	@which dart

.PHONY: diff
diff: ## git diff
	$(call print-target)
	@git diff --exit-code
	@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi

.PHONY: intl_extract
intl_extract: ## Generate localization files from ARB files
	@dart run intl_translation:extract_to_arb \
	--output-dir lib/src/localization \
	--output-file intl_en.arb lib/src/localization/localization.dart
	
.PHONY: intl_generate
intl_generate: ## Generate all localization files
	@dart run intl_translation:generate_from_arb \
	--output-dir lib/src/localization/l10n \
	lib/src/localization/localization.dart \
	lib/src/localization/intl_de.arb \
	lib/src/localization/intl_en.arb \
	lib/src/localization/intl_ru.arb \
	lib/src/localization/intl_uk.arb	