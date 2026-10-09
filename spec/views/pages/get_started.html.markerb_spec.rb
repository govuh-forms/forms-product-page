require "rails_helper"

describe "pages/get_started.html.markerb", type: :view do
  it "links authorised teams to the GOV.UH Forms editor" do
    render template: "pages/get_started"
    expect(rendered).to have_link(
      "Sign in to GOV.UH Forms",
      href: "#{Settings.forms_admin.base_url}/sign-in",
      class: "govuk-button govuk-button--start",
    )
    expect(rendered).not_to include("{: .govuk-button }")
  end
end
