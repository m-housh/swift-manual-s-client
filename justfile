docker_image := "manual-s"
docker_tag := "latest"

clean:
	rm -rf .build

install-deps:
	@curl -sL daisyui.com/fast | bash

run-css:
	@./tailwindcss -i Public/css/main.css -o Public/css/output.css --watch

run *ARGS:
	@swift run server serve --port 8081 {{ARGS}}

build-docker file="Dockerfile":
	@docker build -f {{file}} -t {{docker_image}}:{{docker_tag}} .

run-docker:
	@docker run -it --rm -v $PWD:/app -p 8080:8080 {{docker_image}}:{{docker_tag}}

test-docker: (build-docker "Dockerfile")
	@docker run --rm {{docker_image}}:{{docker_tag}} swift test

code-coverage:
	@llvm-cov report \
		"$(find $(swift build --show-bin-path) -name '*.xctest')" \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests" \
		-use-color

test *ARGS:
	@swift test --enable-code-coverage {{ARGS}}

