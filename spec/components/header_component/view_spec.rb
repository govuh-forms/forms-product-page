require "rails_helper"

RSpec.describe HeaderComponent::View, type: :component do
  let(:phase_name) { "Beta" }

  let(:header_component) do
    described_class.new(phase_name:)
  end

  before do
    render_inline header_component
  end

  describe "render" do
    it "uses the approved GOV.UH wordmark and native Forms product name" do
      expect(page).to have_css("img.govuk-header__logotype.govuh-shared-logo[alt='GOV.UH']")
      expect(page).to have_css(".govuk-header__product-name", text: "Forms")
      expect(page).to have_link(href: "/")
    end

    it "has a full width border" do
      expect(page).to have_css(".govuk-header--full-width-border")
    end
  end
end
