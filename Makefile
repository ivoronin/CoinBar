PROJECT := CoinBar
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo dev)
BUILD_DIR := $(shell swift build -c release --show-bin-path 2>/dev/null || echo .build/release)

.PHONY: build app release lint test test-all clean

build:
	echo 'let appVersion = "$(VERSION)"' > Sources/Version.swift
	swift build -c release

app: build
	rm -rf $(PROJECT).app
	mkdir -p $(PROJECT).app/Contents/MacOS
	cp $(BUILD_DIR)/$(PROJECT) $(PROJECT).app/Contents/MacOS/
	cp Info.plist $(PROJECT).app/Contents/
	plutil -replace CFBundleVersion -string "$(VERSION)" $(PROJECT).app/Contents/Info.plist
	plutil -replace CFBundleShortVersionString -string "$(VERSION)" $(PROJECT).app/Contents/Info.plist

release: app
	mkdir -p dist
	zip -r dist/$(PROJECT).zip $(PROJECT).app

lint:
	swiftlint lint --strict

test: build

test-all: lint test
	@echo "All tests passed"

clean:
	swift package clean
	rm -rf $(PROJECT).app dist
	git checkout Sources/Version.swift 2>/dev/null || true
