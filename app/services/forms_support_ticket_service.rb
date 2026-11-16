require "net/http"
require "openssl"

class FormsSupportTicketService
  class DeliveryError < StandardError; end

  class << self
    def configured?
      ENV["FORMS_SUPPORT_API_SECRET"].present? && ENV["FORMS_SUPPORT_API_URL"].present?
    end

    def create!(comment:, requester:, tags:)
      category = tags.include?("govuk_forms_support") ? "using_forms" : "about_forms"
      body = { support_enquiry: {
        category:,
        name: requester.fetch(:name),
        email: requester[:email],
        discord_contact: requester[:discord_contact],
        message: comment.fetch(:body)
      } }.to_json
      signed_request!(:post, "", body)
    end

    def status!(token)
      raise DeliveryError, "Invalid reference" unless token.match?(/\A[A-Za-z0-9_-]{35,60}\z/)
      signed_request!(:get, "/status/#{token}", "")
    end

    private

    def signed_request!(method, suffix, body)
      raise DeliveryError, "Support service is not configured" unless configured?
      uri = URI.parse(ENV.fetch("FORMS_SUPPORT_API_URL") + suffix)
      raise DeliveryError, "Unsupported support service address" unless uri.scheme == "http" && uri.host == "127.0.0.1"
      now = Time.now.to_i.to_s
      signature = OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("FORMS_SUPPORT_API_SECRET"), "#{now}.#{body}")
      request = method == :post ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
      request["X-UH-Support-Timestamp"] = now
      request["X-UH-Support-Signature"] = signature
      request["Content-Type"] = "application/json"
      request.body = body if method == :post
      response = Net::HTTP.start(uri.host, uri.port, open_timeout: 3, read_timeout: 6) { |http| http.request(request) }
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      elsif response.code.to_i == 404
        raise DeliveryError, "That case could not be found"
      else
        raise DeliveryError, "Support service did not accept the request (#{response.code})"
      end
    rescue JSON::ParserError, IOError, SocketError, Timeout::Error, Errno::ECONNREFUSED => error
      Rails.logger.error("GOV.UH Forms support delivery failed: #{error.class}")
      raise DeliveryError, "The support service could not accept the request. Please try again."
    end
  end
end
