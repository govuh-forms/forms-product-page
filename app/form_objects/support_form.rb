class SupportForm
  include ActiveModel::Model
  include ActiveModel::Validations

  EMAIL_REGEX = /.*@.*/
  I_NEED_HELP_WITH_OPTIONS = %w[using_forms about_forms other_government_service].freeze

  attr_accessor :i_need_help_with, :message, :name, :email_address, :discord_contact

  alias_attribute :question, :message

  validates :i_need_help_with, presence: true, inclusion: { in: I_NEED_HELP_WITH_OPTIONS }
  validates :i_need_help_with, presence: true, inclusion: { in: I_NEED_HELP_WITH_OPTIONS - %w[other_government_service] }, on: :submit
  validates :message, presence: true, on: :submit, if: :i_need_help_with_using_forms?
  validates :question, presence: true, on: :submit, unless: :i_need_help_with_using_forms?
  validates :name, presence: true, on: :submit
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP, message: :invalid_email }, allow_blank: true, on: :submit
  validates :discord_contact, length: { maximum: 100 }, allow_blank: true, on: :submit
  validate :contact_detail_present, on: :submit

  def contact_detail_present
    errors.add(:base, "Provide an email address or Discord username or user ID") if email_address.blank? && discord_contact.blank?
  end

  def submit
    return false if invalid?(:submit)

    tags = {
      "using_forms" => %w[govuk_forms_support],
      "about_forms" => %w[govuk_forms_enquiries],
    }[i_need_help_with]

    FormsSupportTicketService.create!(
      comment: { body: message },
      requester: { name:, email: email_address, discord_contact: },
      tags:,
    )
  end

  def i_need_help_with_using_forms?
    return false if i_need_help_with.blank?

    i_need_help_with.to_sym == :using_forms
  end
end
