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

    unless FormsSupportTicketService.configured?
      @support_form.errors.add(:base, "The online support form is not accepting messages. Use the Government Digital Service contact information linked below.")
      render :form, status: :service_unavailable
      return
    end

    if (result = @support_form.submit)
      @ticket_reference = result.fetch("reference")
      @ticket_status_url = support_case_status_path(result.fetch("access_token"))
      response.headers["Cache-Control"] = "no-store"
      response.headers["Referrer-Policy"] = "no-referrer"
      render :confirmation
    else
      render :form, status: :unprocessable_entity
    end
  rescue FormsSupportTicketService::DeliveryError
    @support_form.errors.add(:base, "Your message has not been sent. Please try again.")
    render :form, status: :service_unavailable
  end

  def case_status
    @case_details = FormsSupportTicketService.status!(params[:access_token])
    response.headers["Cache-Control"] = "no-store"
    response.headers["Referrer-Policy"] = "no-referrer"
    render :case_status
  rescue FormsSupportTicketService::DeliveryError
    render plain: "Case not found or temporarily unavailable", status: :not_found
  end

private

  def support_form_params
    params
      .require(:support_form)
      .permit(:i_need_help_with, :message, :question, :name, :email_address, :discord_contact)
  end
end
