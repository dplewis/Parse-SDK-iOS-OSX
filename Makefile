BUILD_DIR   = $(CURDIR)/Build
ARCHIVE_DIR = $(BUILD_DIR)/Archives
PRODUCT_DIR = $(BUILD_DIR)/Product
FWK_PATH    = /Products/@rpath/Parse.framework
XCODEDIST   = xcodebuild -workspace "$(CURDIR)/Parse.xcworkspace"
XCODEBUILD	= xcodebuild
SHELL       = /bin/bash -e -o pipefail

.PHONY: macos ios tvos watchos archives xcframework

all: archives xcframework

archives: ios tvos watchos

ios:
	@echo "** Building iOS frameworks..."
	$(XCODEDIST) archive -scheme "Parse-iOS" -destination 'generic/platform=iOS' -archivePath $(ARCHIVE_DIR)/Parse-iOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c
	# $(XCODEDIST) archive -scheme "Parse-iOS" -destination 'generic/platform=iOS Simulator' -archivePath $(ARCHIVE_DIR)/Parse-iOS-sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c

tvos:
	@echo "** Building tvOS frameworks..."
	$(XCODEDIST) archive -scheme "Parse-tvOS" -destination 'generic/platform=tvOS' -archivePath $(ARCHIVE_DIR)/Parse-tvOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c
	$(XCODEDIST) archive -scheme "Parse-tvOS" -destination 'generic/platform=tvOS Simulator' -archivePath $(ARCHIVE_DIR)/Parse-tvOS-sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c

watchos:
	@echo "** Building watchOS frameworks..."
	$(XCODEDIST) archive -scheme "Parse-watchOS" -destination 'generic/platform=watchOS' -archivePath $(ARCHIVE_DIR)/Parse-watchOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c
	$(XCODEDIST) archive -scheme "Parse-watchOS" -destination 'generic/platform=watchOS Simulator' -archivePath $(ARCHIVE_DIR)/Parse-watchOS-sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c

macos:
	@echo "** Building macOS framework..."
	$(XCODEDIST) archive -scheme "Parse-macOS" -destination 'generic/platform=macOS' -archivePath $(ARCHIVE_DIR)/Parse-macOS SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty -c

# TODO: macos
xcframework:
	@echo "** Creating XCFrameworks..."
	rm -rf $(PRODUCT_DIR)/Parse.xcframework
	$(XCODEBUILD) -create-xcframework \
		-framework $(ARCHIVE_DIR)/Parse-iOS.xcarchive$(FWK_PATH)
		# -framework $(ARCHIVE_DIR)/Parse-iOS-sim.xcarchive$(FWK_PATH) \
		# -framework $(ARCHIVE_DIR)/Parse-tvOS.xcarchive$(FWK_PATH) \
		# -framework $(ARCHIVE_DIR)/Parse-tvOS-sim.xcarchive$(FWK_PATH) \
		# -framework $(ARCHIVE_DIR)/Parse-watchOS.xcarchive$(FWK_PATH) \
		# -framework $(ARCHIVE_DIR)/Parse-watchOS-sim.xcarchive$(FWK_PATH) \
		-output $(PRODUCT_DIR)/Parse.xcframework

clean:
	rm -rf "$(BUILD_DIR)"
