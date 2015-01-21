PROJECT_NAME=SenseKit
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
DEFAULT_FLAGS=-sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 5s,OS=8.1"
TESTING_TOOL=xcodebuild

DEFAULT_TASK=$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) $(DEFAULT_FLAGS)

default: build

build:
	$(DEFAULT_TASK)

clean:
	$(DEFAULT_TASK) clean

test:
	set -o pipefail && $(DEFAULT_TASK) test | xcpretty -c

install:
	gem install xcpretty  --no-ri --no-rdoc
