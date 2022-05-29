.PHONY: watch
watch:
	find . | entr -rc love2d .
