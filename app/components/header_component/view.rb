module HeaderComponent
  class View < ApplicationComponent
    attr_accessor :phase_name

    def initialize(phase_name: nil)
      super()
      @phase_name = phase_name
    end

    def call
      govuk_header(homepage_url:, classes: "govuk-header--full-width-border") do |header|
        header.with_custom_logo { helpers.image_tag("https://www.gov.uhrblx.com/uh-brand/gov-uh-site-identity-logo.svg", alt: "GOV.UH", width: 162, height: 30, class: "govuk-header__logotype govuh-shared-logo") }
        header.with_product_name(name: "Forms")
      end
    end

  private

    def homepage_url
      root_path
    end
  end
end
