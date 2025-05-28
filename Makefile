OUTPUT_DIR=lib/src/localization/l10n

MESSAGE_ARBS=\
	lib/src/localization/intl_de.arb \
	lib/src/localization/intl_en.arb \
	lib/src/localization/intl_ru.arb \
	lib/src/localization/intl_uk.arb	

generate: $(MESSAGE_ARBS)
	dart run intl_translation:generate_from_arb  \
	--output-dir $(OUTPUT_DIR) \
	lib/src/localization/l10n/example_messages.dart \
	$(MESSAGE_ARBS)

clean:
	rm $(OUTPUT_DIR)/*.dart