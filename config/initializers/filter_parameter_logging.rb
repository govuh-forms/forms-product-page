Rails.application.config.filter_parameters += [
  :message, :question, :name, :email_address, :access_token, :support_form
]

Rails.application.config.filter_parameters += [:discord_contact]
