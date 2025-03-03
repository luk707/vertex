hello: hello.rs
	rustc --target=x86_64-unknown-linux-musl -C opt-level=z -C lto hello.rs

clean:
	rm -f hello

.PHONY: clean
