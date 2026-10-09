require "rails_helper"

describe "pages/terms_of_use.html.erb", type: :view do
  before do
    render template: "pages/terms_of_use"
  end

  it "sets out authorised use, security, information handling and accessibility" do
    expect(rendered).to have_text("These terms apply to authorised government users of GOV.UH Forms.")
    expect(rendered).to have_text("Use the service for authorised government work")
    expect(rendered).to have_text("Security")
    expect(rendered).to have_text("Completed form data")
    expect(rendered).to have_text("Data protection")
    expect(rendered).to have_text("Accessibility and service quality")
    expect(rendered).to have_text("Changes to these terms")
  end
end
