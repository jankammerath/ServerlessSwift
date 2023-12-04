build:
	docker run --rm --platform linux/arm64 -v "$(PWD):/src" -w /src swift:5.9.1-amazonlinux2 /bin/bash \
		-c "swift build --product ServerlessSwift -c release -Xswiftc -static-stdlib; mv .build/release/ServerlessSwift bootstrap"