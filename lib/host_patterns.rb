module HostPatterns
  DEFAULT_HOST_PATTERNS = [
    /\Aforms\.service\.gov\.uhrblx\.com\z/,
    /\Awww\.forms\.service\.gov\.uhrblx\.com\z/,
  ].freeze

  def self.allowed_host_patterns
    additional_patterns = ENV.fetch("ALLOWED_HOST_PATTERNS", "").split(",").map { |pattern| Regexp.new(pattern.strip) }

    [*DEFAULT_HOST_PATTERNS, *additional_patterns]
  end
end
