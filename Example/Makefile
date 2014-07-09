PROJECT_NAME=SenseKit
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
DEFAULT_FLAGS=-sdk iphonesimulator
TESTING_TOOL=xcodebuild

DEFAULT_TASK=$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) $(DEFAULT_FLAGS)

default: build

build:
	$(DEFAULT_TASK)

clean:
	$(DEFAULT_TASK) clean

test:
	$(DEFAULT_TASK) test | tee xcodebuild.log

install:
	gem install xcpretty  --no-ri --no-rdoc