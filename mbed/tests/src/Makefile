all:
	@mkdir -p ../gcov_files
	@mkdir -p ../gcov_files/temp
	
	@for a in $$(ls); do \
		if [ -d $$a ]; then \
			$(MAKE) -C $$a all run coverage_collect || exit 1; \
		fi; \
	done;

	lcov $(foreach file,$(shell find -type d | grep './' | sed 's/\.\///g'),-a ../gcov_files/temp/$(file).info) -o ../gcov_files/temp/app.info
	genhtml --no-branch-coverage ../gcov_files/temp/app.info -o ../results/

clean:
	@for a in $$(ls); do \
		if [ -d $$a ]; then \
			$(MAKE) -C $$a clean || exit 1; \
		fi; \
	done;

	@rm -rfv ../gcov_files
	@rm -rfv ../results