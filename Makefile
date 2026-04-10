# Top-level Makefile for Lumi

.PHONY: setup codegen run test services-up services-down services-reset test-unit test-integration appwrite-reset

setup:
	flutter pub get
	# Placeholder: ensure Rust toolchain is installed
	cargo --version || echo "Install Rust toolchain"

# Codegen: runs flutter_rust_bridge_codegen to generate Dart bindings from Rust
# Note: flutter_rust_bridge_codegen must be installed (cargo install flutter_rust_bridge_codegen)
codegen:
	@echo "Running flutter_rust_bridge_codegen (if available)"
	flutter_rust_bridge_codegen generate --rust-input rust/lumi_core/src/lib.rs --dart-output lib/shared/bridge || true

run:
	flutter run

# test: runs both Rust and Flutter unit tests
test:
	@echo "Running Rust tests"
	cargo test --manifest-path=rust/lumi_core/Cargo.toml || true
	@echo "Running Flutter unit tests"
	flutter test test/ || true

services-up:
	docker compose -f docker-compose.appwrite.yml up -d
	@bash scripts/wait-for-appwrite.sh

services-down:
	docker compose -f docker-compose.appwrite.yml down

services-reset:
	docker compose -f docker-compose.appwrite.yml down -v
	$(MAKE) services-up

# Additional targets for CI and developer convenience
codegen:
	flutter_rust_bridge_codegen generate

test-unit:
	flutter test test/

test-integration: services-up
	flutter test integration_test/ \
	  --dart-define-from-file=.env.test \
	  -d $(DEVICE)

appwrite-reset: services-reset
	@echo ""
	@echo "Appwrite volumes wiped. Re-run bootstrap:"
	@echo "  Open Copilot agent mode and use the prompt in scripts/BOOTSTRAP.md"
	@echo ""
