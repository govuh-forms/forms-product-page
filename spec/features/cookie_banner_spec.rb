require "rails_helper"

feature "GOV.UH Forms public website without optional analytics", type: :system do
  it "does not display an analytics cookie banner or install analytics" do
    visit root_path
    expect(page).not_to have_selector("#cookie-banner")
    expect(page).not_to have_selector('script[src*="googletagmanager"]', visible: :hidden)
  end

  it "does not offer an irrelevant analytics consent choice" do
    visit root_path
    expect(page).not_to have_button("Accept analytics cookies")
    expect(page).not_to have_button("Reject analytics cookies")
  end
end
