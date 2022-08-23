all:
	python ${OPENSCADPATH}/NopSCADLib/scripts/make_all.py

update:
	git add Makefile scad/ assemblies/ stls/ bom/ printme.html readme.html readme.md
	git commit -m 'update to project'
	git push origin main