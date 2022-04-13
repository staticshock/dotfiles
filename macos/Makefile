.PHONY: sort
sort:
	@plutil -convert json -r -e json NSUserDictionaryReplacementItems.plist
	@jq 'sort_by(.shortcut)' NSUserDictionaryReplacementItems.json | \
		plutil -convert xml1 -o NSUserDictionaryReplacementItems.plist -
	@rm NSUserDictionaryReplacementItems.json
