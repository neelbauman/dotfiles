.PHONY: build install clean test lint check

BUILD_DIR := .build

build:
	cargo build --release

install: build
	cargo install --path .

test:
	cargo test -- --nocapture

lint:
	cargo clippy -- -D warnings

check: lint test

clean:
	cargo clean
	rm -rf $(BUILD_DIR)
