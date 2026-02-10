# name: discourse-ai-translation-sanitizer
# about: Replaces escaped sequences in post raw before saving to DB
# version: 0.1
# authors: JesusBYS
# url: https://github.com/JesusBYS/discourse-ai-translation-sanitizer

enabled_site_setting :ai_translation_sanitizer_enabled

after_initialize do
  module ::AiTranslationSanitizer
    def self.sanitize_raw(raw)
      return raw if raw.blank?

      raw
        .gsub("\\u003e", ">")  # remplace la séquence littérale \u003e
        .gsub("\\n", "\n")     # remplace la séquence littérale \n par un vrai saut de ligne
    end
  end

  ::Post.class_eval do
    before_validation do
      next unless SiteSetting.ai_translation_sanitizer_enabled
      next if self.raw.blank?

      sanitized = ::AiTranslationSanitizer.sanitize_raw(self.raw)
      self.raw = sanitized if sanitized != self.raw
    end
  end
end
