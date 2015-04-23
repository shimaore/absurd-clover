all: dirs assets local/index.html
	tar -xzf assets/tzdata-latest.tar.gz -C assets/tz

local/index.html: src/index.coffee package.json
	./node_modules/.bin/coffee build.coffee

dirs:
	mkdir -p assets/ assets/tz/ local/

assets: assets/jquery.flot.js assets/jquery.flot.time.js assets/jquery.flot.navigate.js assets/jquery.flot.tooltip.js assets/coffee-script.js assets/jquery.min.js assets/date.js assets/tzdata-latest.tar.gz assets/jquery.dataTables.min.css assets/jquery.dataTables.min.js

clean:
	rm -rf assets/

assets/jquery.flot.js:
	curl -o $@ -L https://raw.github.com/flot/flot/master/jquery.flot.js

assets/jquery.flot.time.js:
	curl -o $@ -L https://raw.github.com/flot/flot/master/jquery.flot.time.js

assets/jquery.flot.navigate.js:
	curl -o $@ -L https://raw.github.com/flot/flot/master/jquery.flot.navigate.js

assets/jquery.flot.tooltip.js:
	curl -o $@ -L https://raw.github.com/krzysu/flot.tooltip/master/js/jquery.flot.tooltip.js

assets/coffee-script.js:
	curl -o $@ -L https://raw.github.com/jashkenas/coffee-script/master/extras/coffee-script.js

assets/jquery.min.js:
	curl -o $@ -L http://code.jquery.com/jquery-1.9.1.min.js

assets/date.js:
	curl -o $@ -L https://raw.github.com/mde/timezone-js/master/src/date.js

assets/tzdata-latest.tar.gz:
	curl -o $@ ftp://ftp.iana.org/tz/tzdata-latest.tar.gz

assets/jquery.dataTables.min.css:
	curl -o $@ -L https://cdn.datatables.net/1.10.6/css/jquery.dataTables.min.css

assets/jquery.dataTables.min.js:
	curl -o $@ -L https://cdn.datatables.net/1.10.6/js/jquery.dataTables.min.js

index.js: index.coffee
	coffee -c $<

push: all index.js
	./node_modules/.bin/couchapp push index.js `cdrs-url`
sync: all index.js
	./node_modules/.bin/couchapp sync index.js `cdrs-url`
