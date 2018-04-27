build_tool = runtime-container.DONE
#git_commit ?= $(shell git log --pretty=oneline -n 1 -- ../samtools | cut -f1 -d " ")
name = bmwlee/usyd_gembs
tag = 2.1

build: ${build_tool}

${build_tool}: Dockerfile
	docker build -t ${name}:${tag} .
	docker tag ${name}:${tag} ${name}:latest
	touch ${build_tool}

push: build
	# Requires ~/.dockercfg
	docker push ${name}:${tag}
	docker push ${name}:latest

test: build
	python test.py

clean:
	-rm ${build_tool}
