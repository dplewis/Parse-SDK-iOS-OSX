BUILD_DIR   = $(CURDIR)/Build
ARCHIVE_DIR = $(BUILD_DIR)/Archives
PRODUCT_DIR = $(BUILD_DIR)/Product
FWK_PATH    = /Products/Library/Frameworks/Parse.framework
XCODEDIST   = xcodebuild -workspace "$(CURDIR)/Parse.xcworkspace"
XCODEBUILD	= xcodebuild
SHELL       = /bin/bash -e -o pipefail

.PHONY: macos ios tvos watchos buildcheck archives xcframework

clean:
	rm -rf "$(BUILD_DIR)"

test: test-macos test-ios 

test-macos:
	@echo "Running macOS tests..."
	$(XCODECI) -scheme OCMock -destination 'platform=macOS' test | xcpretty -c

test-ios:
	@echo "Running iOS tests..."
	$(XCODECI) -scheme OCMockLib -destination 'platform=iOS Simulator,OS=latest,name=iPhone 15' test | xcpretty -c

release: archives xcframework

macos:
	@echo "** Building macOS framework..."
	$(XCODEDIST) archive -scheme "Parse-macOS" -destination 'generic/platform=macOS' -archivePath $(ARCHIVE_DIR)/Parse-macOS | xcpretty -c

ios:
	@echo "** Building iOS frameworks..."
	$(XCODEDIST) archive -scheme "Parse-iOS" -destination 'generic/platform=iOS' -archivePath $(ARCHIVE_DIR)/Parse-iOS | xcpretty -c
	$(XCODEDIST) archive -scheme "Parse-iOS" -destination 'generic/platform=iOS Simulator' -archivePath $(ARCHIVE_DIR)/Parse-iOS-sim | xcpretty -c

tvos:
	@echo "** Building tvOS frameworks..."
	$(XCODEDIST) archive -scheme "Parse-tvOS" -destination 'generic/platform=tvOS' -archivePath $(ARCHIVE_DIR)/Parse-tvOS | xcpretty -c
	$(XCODEDIST) archive -scheme "Parse-tvOS" -destination 'generic/platform=tvOS Simulator' -archivePath $(ARCHIVE_DIR)/Parse-tvOS-sim | xcpretty -c

watchos:
	@echo "** Building watchOS frameworks..."
	$(XCODEDIST) archive -scheme "Parse-watchOS" -destination 'generic/platform=watchOS' -archivePath $(ARCHIVE_DIR)/Parse-watchOS | xcpretty -c
	$(XCODEDIST) archive -scheme "Parse-watchOS" -destination 'generic/platform=watchOS Simulator' -archivePath $(ARCHIVE_DIR)/Parse-watchOS-sim | xcpretty -c


archives: macos ios tvos watchos

# TODO: Build Parse.Framework into Archives to generate Parse.xcframework
xcframework:
	@echo "** Creating XCFrameworks..."
	rm -rf $(PRODUCT_DIR)/Parse.xcframework
	$(XCODEBUILD) -create-xcframework -output $(PRODUCT_DIR)/Parse.xcframework \
		-framework $(ARCHIVE_DIR)/Parse-macOS.xcarchive$(FWK_PATH) \
		-framework $(ARCHIVE_DIR)/Parse-iOS.xcarchive$(FWK_PATH) \
		-framework $(ARCHIVE_DIR)/Parse-iOS-sim.xcarchive$(FWK_PATH) \
		-framework $(ARCHIVE_DIR)/Parse-tvOS.xcarchive$(FWK_PATH) \
		-framework $(ARCHIVE_DIR)/Parse-tvOS-sim.xcarchive$(FWK_PATH) \
		-framework $(ARCHIVE_DIR)/Parse-watchOS.xcarchive$(FWK_PATH) \
		-framework $(ARCHIVE_DIR)/Parse-watchOS-sim.xcarchive$(FWK_PATH)
