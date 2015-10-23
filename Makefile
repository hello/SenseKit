PROJECT_NAME=SenseKit
COMPANY_ID=is.hello
DOCSET_DIR=$(COMPANY_ID).$(PROJECT_NAME)
DOCSET_BUILD_DIR=docset_build
DOCTOOL=appledoc --project-name $(PROJECT_NAME) --project-company Hello --company-id $(COMPANY_ID) --index-desc README.md --search-undocumented-doc --keep-undocumented-objects

default: test

ci_deps:
	    gem install xcpretty --no-ri --no-rdoc -v 0.1.12

ci: 
		$(MAKE) -C Example circleci

clean:
		$(MAKE) -C Example clean

test:
		$(MAKE) -C Example test

install:
		# gem install docstat --no-ri --no-rdoc
		$(MAKE) -C Example install

build_html:
		$(DOCTOOL) -h --output Documentation/  --keep-intermediate-files Classes/ || true
		rm -r Documentation/docset/

build_docset:
		rm -rf $(DOCSET_BUILD_DIR) && rm -rf $(DOCSET_DIR) && mkdir $(DOCSET_BUILD_DIR)
		$(DOCTOOL) -d --keep-intermediate-files --output $(DOCSET_BUILD_DIR) Classes/ || true
		mv $(DOCSET_BUILD_DIR)/docset $(DOCSET_DIR)
		rm -rf $(DOCSET_BUILD_DIR)

test_coverage:
		docstat-test $(DOCSET_DIR) 0.8

install_docs:
		$(DOCTOOL) Classes/

compile_protobuf:
		protoc --proto_path=./Pod/Classes/BLE/Protobuf/ --objc_out=Pod/Classes/BLE/ Pod/Classes/BLE/Protobuf/SENSenseMessage.proto
