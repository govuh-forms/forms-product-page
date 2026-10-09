require "rails_helper"

feature "GOV.UH Forms Support", type: :system do
  scenario "offers the three native support choices" do
    visit support_path
    expect(page).to have_text("What do you need help with?")
    expect(page).to have_field("support_form[i_need_help_with]", type: :radio, visible: :all).exactly(3).times
  end

  scenario "shows a contact route instead of pretending to deliver a ticket" do
    visit support_path
    choose "I work in a government service team and need help using GOV.UH Forms", visible: :all
    click_button "Continue"

    expect(page).to have_text("Help using GOV.UH Forms")
    expect(page).to have_text("The GOV.UH Forms support form is not currently accepting messages.")
    expect(page).to have_link("Government Digital Service contact information")
    expect(page).not_to have_button("Send")
  end

  context "with a configured support-ticket provider" do
    before do
      allow(Settings.zendesk).to receive_messages(
        api_user: "qa@example.org",
        api_token: "unit-test-token",
        subdomain: "uh-forms-unit-test",
      )
      stub_request(:post, "https://uh-forms-unit-test.zendesk.com/api/v2/tickets.json")
        .to_return { |request| { status: 201, body: request.body } }
    end

    scenario "submits a help request through the original form flow" do
      visit support_path
      choose "I work in a government service team and need help using GOV.UH Forms", visible: :all
      click_button "Continue"

      fill_in "Your message", with: "I need help with Forms"
      fill_in "Your name", with: "Test User"
      fill_in "Your email address", with: "test@example.org"
      click_button "Send"
      expect(page).to have_text("Message sent")
    end

    scenario "submits a general question through the original form flow" do
      visit support_path
      choose "I work in a government service team and have a question about GOV.UH Forms", visible: :all
      click_button "Continue"

      fill_in "Your question", with: "Please advise"
      fill_in "Your name", with: "Test User"
      fill_in "Your email address", with: "test@example.org"
      click_button "Send"
      expect(page).to have_text("Message sent")
    end
  end

  scenario "members of the public go to the UH contact service" do
    visit support_path
    choose "I’m a member of the public with a question about a government form or service", visible: :all
    click_button "Continue"

    expect(page).to have_current_path("https://www.gov.uhrblx.com/contact", url: true)
  end
end
