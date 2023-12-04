clean:
	rm -rf .build
	rm -f bootstrap
	rm -f Package.resolved

build:
	docker run --rm --platform linux/arm64 -v "$(PWD):/src" -w /src swift:5.9.1-amazonlinux2 /bin/bash \
		-c "swift build --product ServerlessSwift -c release --static-swift-stdlib -Xswiftc -static-stdlib; mv .build/release/ServerlessSwift bootstrap"