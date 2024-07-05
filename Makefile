run:
	@if [ -z "$(file)" ]; then \
		echo "Usage: make run file=path/to/your/file.dtr"; \
  		exit 1; \
  fi; \
	./soroban_rust_backend $(file)

version:
	@./soroban_rust_backend version