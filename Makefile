

clean:
	rm -f -rf .dub/
	rm -f -rf examples/hello_world/.dub/
	rm -f -rf wrapper_generate/.dub/
	rm -f -rf wrapper_builder/.dub/
	rm -f dub.selections.json
	rm -f examples/hello_world/dub.selections.json
	rm -f wrapper_generate/dub.selections.json
	rm -f wrapper_builder/dub.selections.json

	rm -f examples/hello_world/hello_world
	rm -f wrapper_generate/wrapper_generate
	rm -f wrapper_generate/wrapped.d
	rm -f wrapper_builder/wrapper_builder
	rm -f -rf lib
