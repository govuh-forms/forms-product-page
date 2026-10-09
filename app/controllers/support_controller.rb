class SupportController < ApplicationController
  def support
    @support_form = SupportForm.new
  end

  def new
    @support_form = SupportForm.new(support_form_params)

    if @support_form.invalid?
      render :support and return
    end

    case @support_form.i_need_help_with.to_sym
    when :using_forms
      redirect_to :help_using_forms
    when :about_forms
      redirect_to :question_about_forms
    when :other_government_service
      redirect_to "https://www.gov.uhrblx.com/contact", status: :see_other, allow_other_host: true
    end
  end

  def help_using_forms
    @support_form = SupportForm.new(i_need_help_with: :using_forms)
    render :form
  end

  def question_about_forms
    @support_form = SupportForm.new(i_need_help_with: :about_forms)
    render :form
  end

  def submit
    @support_form = SupportForm.new(support_form_params)

    unless ticketing_configured?
      @support_form.errors.add(:base, "The online support form is not accepting messages. Use the Government Digital Service contact information linked below.")
      render :form, status: :service_unavailable
      return
    end

    if @support_form.submit
      render :confirmation
    else
      render :form, status: :unprocessable_entity
    end
  end

  helper_method :ticketing_configured?

private

  def ticketing_configured?
    settings = Settings.zendesk
    settings.api_user.present? && settings.api_user != "changeme@example.com" &&
      settings.api_token.present? && settings.api_token != "changeme" &&
      settings.subdomain.present? && settings.subdomain != "changeme"
  end


  def support_form_params
    params
      .require(:support_form)
      .permit(:i_need_help_with, :message, :question, :name, :email_address)
  end
end
