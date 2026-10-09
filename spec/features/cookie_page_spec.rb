require "rails_helper"

feature "GOV.UH Forms cookies information", type: :system do
  before do
    visit cookies_path
  end

  it "discloses the current analytics and essential cookie position" do
    expect(page).to have_text("GOV.UH Forms does not currently use optional analytics cookies")
    expect(page).to have_text("Essential cookies")
    expect(page).not_to have_button("Save cookie settings")
  end

  it "does not load Google analytics" do
    expect(page).not_to have_selector('script[src*="googletagmanager"]', visible: :hidden)
  end
end
