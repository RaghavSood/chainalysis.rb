# frozen_string_literal: true

require 'faraday'
require 'json'

module Chainalysis
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class BadRequestError < Error; end
  class NotFoundError < Error; end
  class RateLimitError < Error; end
  class ApiError < Error; end

  # Base client class handling common functionality
  class BaseClient
    BASE_URL = 'https://api.chainalysis.com/api/kyt'
    ADMIN_URL = 'https://api.chainalysis.com/admin'
    VERSION = '0.2.0'

    attr_reader :api_key, :adapter

    def initialize(api_key:, adapter: Faraday.default_adapter, stubs: nil)
      @api_key = api_key
      @adapter = adapter
      @stubs = stubs
    end

    protected

    def client
      @client ||= Faraday.new(url: BASE_URL) do |conn|
        conn.headers['Token'] = api_key
        conn.headers['Accept'] = 'application/json'
        conn.headers['Content-Type'] = 'application/json'
        conn.adapter adapter, @stubs
      end
    end

    def admin_client
      @admin_client ||= Faraday.new(url: ADMIN_URL) do |conn|
        conn.headers['Token'] = api_key
        conn.headers['Accept'] = 'application/json'
        conn.headers['Content-Type'] = 'application/json'
        conn.adapter adapter, @stubs
      end
    end

    def handle_response(response)
      case response.status
      when 200, 201, 202
        return {} if response.body.empty?

        JSON.parse(response.body)
      when 400
        raise BadRequestError, error_message(response)
      when 403
        raise AuthenticationError, error_message(response)
      when 404
        raise NotFoundError, error_message(response)
      when 429
        raise RateLimitError, error_message(response)
      else
        raise ApiError, error_message(response)
      end
    end

    def error_message(response)
      return response.body if response.body.empty?

      error = JSON.parse(response.body)
      error['message'] || error['error'] || response.body
    rescue JSON::ParserError
      response.body
    end

    def get_request(url, params = {}, admin: false)
      client = admin ? admin_client : self.client
      response = client.get(url) do |req|
        req.params = params if params
      end
      handle_response(response)
    end

    def post_request(url, body = {})
      response = client.post(url) do |req|
        req.body = JSON.generate(body) unless body.empty?
      end
      handle_response(response)
    end

    def delete_request(url)
      response = client.delete(url)
      handle_response(response)
    end
  end

  # Client for V1 API endpoints
  class V1Client < BaseClient
    # Transfer endpoints
    def register_received_transfer(user_id:, transfers:)
      post_request("v1/users/#{user_id}/transfers/received", transfers)
    end

    def get_received_transfers(user_id:, limit: nil, offset: nil)
      params = {}
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      get_request("v1/users/#{user_id}/transfers/received", params)
    end

    def register_sent_transfer(user_id:, transfers:)
      post_request("v1/users/#{user_id}/transfers/sent", transfers)
    end

    def get_sent_transfers(user_id:, limit: nil, offset: nil)
      params = {}
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      get_request("v1/users/#{user_id}/transfers/sent", params)
    end

    # Withdrawal address endpoints
    def register_withdrawal_addresses(user_id:, addresses:)
      post_request("v1/users/#{user_id}/withdrawaladdresses", addresses)
    end

    def get_withdrawal_addresses(user_id:, limit: nil, offset: nil)
      params = {}
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      get_request("v1/users/#{user_id}/withdrawaladdresses", params)
    end

    def delete_withdrawal_address(user_id:, asset:, address:)
      delete_request("v1/users/#{user_id}/withdrawaladdresses/#{asset}/#{address}")
    end

    # Deposit address endpoints
    def register_deposit_addresses(user_id:, addresses:)
      post_request("v1/users/#{user_id}/depositaddresses", addresses)
    end

    def get_deposit_addresses(user_id:, limit: nil, offset: nil)
      params = {}
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      get_request("v1/users/#{user_id}/depositaddresses", params)
    end

    def delete_deposit_address(user_id:, asset:, address:)
      delete_request("v1/users/#{user_id}/depositaddresses/#{asset}/#{address}")
    end

    # Alert endpoints
    def get_alerts(params = {})
      get_request('v1/alerts/', params)
    end

    def assign_alert(alert_identifier:, alert_assignee:)
      post_request("v1/alerts/#{alert_identifier}/assignment",
                   { alertAssignee: alert_assignee })
    end

    def update_alert_status(alert_identifier:, status:, comment: nil)
      body = { status: status }
      body[:comment] = comment if comment
      post_request("v1/alerts/#{alert_identifier}/statuses", body)
    end

    def get_alert_activity(alert_identifier:)
      get_request("v1/alerts/#{alert_identifier}/activity")
    end

    # User endpoints
    def get_users(limit: nil, offset: nil)
      params = {}
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      get_request('v1/users/', params)
    end

    def get_user(user_id:)
      get_request("v1/users/#{user_id}")
    end

    def rename_users(renames:)
      post_request('v1/users/rename', renames)
    end
  end

  # Client for V2 API endpoints
  class V2Client < BaseClient
    def register_transfer(user_id:, network:, asset:, transfer_reference:, direction:, **options)
      post_request(
        "v2/users/#{user_id}/transfers",
        {
          network: network,
          asset: asset,
          transferReference: transfer_reference,
          direction: direction,
          **options
        }
      )
    end

    def register_withdrawal_attempt(user_id:, network:, asset:, address:, attempt_identifier:,
                                    asset_amount:, attempt_timestamp:, **options)
      post_request(
        "v2/users/#{user_id}/withdrawal-attempts",
        {
          network: network,
          asset: asset,
          address: address,
          attemptIdentifier: attempt_identifier,
          assetAmount: asset_amount,
          attemptTimestamp: attempt_timestamp,
          **options
        }
      )
    end

    def get_transfer(external_id:, format_type: nil)
      params = { format_type: format_type } if format_type
      get_request("v2/transfers/#{external_id}", params)
    end

    def get_transfer_exposures(external_id:)
      get_request("v2/transfers/#{external_id}/exposures")
    end

    def get_transfer_alerts(external_id:)
      get_request("v2/transfers/#{external_id}/alerts")
    end

    def get_transfer_network_identifications(external_id:)
      get_request("v2/transfers/#{external_id}/network-identifications")
    end

    def get_withdrawal_attempt(external_id:, format_type: nil)
      params = { format_type: format_type } if format_type
      get_request("v2/withdrawal-attempts/#{external_id}", params)
    end

    def get_withdrawal_attempt_exposures(external_id:)
      get_request("v2/withdrawal-attempts/#{external_id}/exposures")
    end

    def get_withdrawal_attempt_alerts(external_id:)
      get_request("v2/withdrawal-attempts/#{external_id}/alerts")
    end

    def get_withdrawal_attempt_high_risk_addresses(external_id:)
      get_request("v2/withdrawal-attempts/#{external_id}/high-risk-addresses")
    end

    def get_withdrawal_attempt_network_identifications(external_id:)
      get_request("v2/withdrawal-attempts/#{external_id}/network-identifications")
    end

    def get_categories
      get_request('v2/categories')
    end

    def get_internal_users
      get_request('organization/users', admin: true)
    end
  end

  # Main client class that provides access to both V1 and V2 clients
  class Client < BaseClient
    def v1
      @v1 ||= V1Client.new(api_key: api_key, adapter: adapter, stubs: @stubs)
    end

    def v2
      @v2 ||= V2Client.new(api_key: api_key, adapter: adapter, stubs: @stubs)
    end
  end
end
