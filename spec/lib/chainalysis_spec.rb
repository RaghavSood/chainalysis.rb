# frozen_string_literal: true

require 'spec_helper'
require 'chainalysis/client'

RSpec.describe Chainalysis::Client do
  let(:api_key) { ENV['API_KEY'] }
  let(:client) { described_class.new(api_key: api_key) }
  let(:user_id) { 'e38a7c51-0168-46e8-899e-6ae70acade5c' }

  describe '#initialize' do
    it 'creates a new client instance' do
      expect(client).to be_a(described_class)
    end

    it 'sets the api key' do
      expect(client.api_key).to eq(api_key)
    end
  end

  describe '#v1' do
    describe '#register_received_transfer' do
      let(:transfer_data) do
        [
          {
            network: 'Bitcoin',
            asset: 'BTC',
            transferReference: '0477742d7bf8ace7d320c4b98fb6a0c3223789bb39526fd52b5dbecb9a707045:1C3vdffe4hvdMVyVkJRs63Ur577w4XDWNv'
          }
        ]
      end

      it 'sends a POST request to register a received transfer' do
        VCR.use_cassette('v1/register_received_transfer') do
          response = client.v1.register_received_transfer(user_id: user_id, transfers: transfer_data)
          expect(response[0]).to include('asset', 'cluster', 'rating', 'transferReference')
        end
      end
    end

    describe '#get_received_transfers' do
      it 'sends a GET request to retrieve received transfers' do
        VCR.use_cassette('v1/get_received_transfers') do
          response = client.v1.get_received_transfers(user_id: user_id)
          expect(response).to include('data')
          expect(response['data'][0]).to include(
            'amount',
            'amountUSD',
            'asset',
            'cluster',
            'rating',
            'timestamp',
            'transferReference'
          )
        end
      end
    end

    describe '#register_sent_transfer' do
      let(:transfer_data) do
        [
          {
            network: 'Bitcoin',
            asset: 'BTC',
            transferReference: 'f43ef1fc4bf50060c0639fe0ae905f69fae5a2b090614b45e353ec7ae042a73d:bc1q9vsudlnammanvycge5k5j7qm7e3l2aej97t09e'
          }
        ]
      end

      it 'sends a POST request to register a sent transfer' do
        VCR.use_cassette('v1/register_sent_transfer') do
          response = client.v1.register_sent_transfer(user_id: user_id, transfers: transfer_data)
          expect(response).to eq({})
        end
      end
    end

    describe '#get_sent_transfers' do
      it 'sends a GET request to retrieve sent transfers' do
        VCR.use_cassette('v1/get_sent_transfers') do
          response = client.v1.get_sent_transfers(user_id: user_id)
          expect(response).to include('limit', 'offset', 'total', 'data')
          expect(response['data'][0]).to include(
            'amount',
            'amountUSD',
            'asset',
            'cluster',
            'timestamp',
            'transferReference'
          )
        end
      end
    end

    describe '#register_withdrawal_addresses' do
      let(:addresses) do
        [
          { network: 'Bitcoin', asset: 'BTC', address: 'bc1qntafv42kpwug7wfjmzzffxysqm5rqfswduheg6' }
        ]
      end

      it 'sends a POST request to register withdrawal addresses' do
        VCR.use_cassette('v1/register_withdrawal_addresses') do
          response = client.v1.register_withdrawal_addresses(user_id: user_id, addresses: addresses)
          expect(response[0]).to include('asset', 'address', 'cluster')
        end
      end
    end

    describe '#get_withdrawal_addresses' do
      it 'sends a GET request to retrieve withdrawal addresses' do
        VCR.use_cassette('v1/get_withdrawal_addresses') do
          response = client.v1.get_withdrawal_addresses(user_id: user_id)
          expect(response).to include('limit', 'offset', 'total', 'data')
          expect(response['data'][0]).to include('asset', 'address', 'cluster')
        end
      end
    end

    describe '#delete_withdrawal_address' do
      it 'sends a DELETE request to delete a withdrawal address' do
        VCR.use_cassette('v1/delete_withdrawal_address') do
          response = client.v1.delete_withdrawal_address(user_id: user_id, asset: 'BTC',
                                                         address: 'bc1qntafv42kpwug7wfjmzzffxysqm5rqfswduheg6')
          expect(response).to eq({})
        end
      end
    end

    describe '#register_deposit_addresses' do
      let(:addresses) do
        [
          { network: 'Ethereum', asset: 'ETH', address: '0x9AC2B9cF6D5a7f60dFa7f2876a5c581A03e4927E' }
        ]
      end

      it 'sends a POST request to register deposit addresses' do
        VCR.use_cassette('v1/register_deposit_addresses') do
          response = client.v1.register_deposit_addresses(user_id: user_id, addresses: addresses)
          expect(response).to eq({})
        end
      end
    end

    describe '#get_deposit_addresses' do
      it 'sends a GET request to retrieve deposit addresses' do
        VCR.use_cassette('v1/get_deposit_addresses') do
          response = client.v1.get_deposit_addresses(user_id: user_id)
          expect(response).to include('limit', 'offset', 'total', 'data')
          expect(response['data'][0]).to include('asset', 'address')
        end
      end
    end

    describe '#delete_deposit_address' do
      it 'sends a DELETE request to delete a deposit address' do
        VCR.use_cassette('v1/delete_deposit_address') do
          response = client.v1.delete_deposit_address(user_id: user_id, asset: 'ETH',
                                                      address: '0x9AC2B9cF6D5a7f60dFa7f2876a5c581A03e4927E')
          expect(response).to eq({})
        end
      end
    end

    describe '#get_alerts' do
      it 'sends a GET request to retrieve alerts' do
        VCR.use_cassette('v1/get_alerts') do
          response = client.v1.get_alerts
          expect(response).to include('limit', 'offset', 'total', 'data')
        end
      end
    end

    describe '#get_users' do
      it 'sends a GET request to retrieve users' do
        VCR.use_cassette('v1/get_users') do
          response = client.v1.get_users
          expect(response).to include('limit', 'offset', 'total', 'data')
        end
      end
    end

    describe '#get_user' do
      it 'sends a GET request to retrieve a user' do
        VCR.use_cassette('v1/get_user') do
          response = client.v1.get_user(user_id: user_id)
          expect(response).to include('userId', 'score', 'lastActivity', 'riskScore')
        end
      end
    end
  end

  describe '#v2' do
    describe '#register_transfer' do
      context 'when the transfer is deposit' do
        let(:transfer_data) do
          {
            network: 'Bitcoin',
            asset: 'BTC',
            transfer_reference: '4a7fd1dbb44bb37e80fcaab177fda3d432c1f383f9483abc8d597a0a1b47cb91:bc1qwa8qddnn8g98kgqjhkh5gpcad8n2y87d6gzh6p',
            direction: 'received'
          }
        end

        it 'sends a POST request to register a transfer' do
          VCR.use_cassette('v2/register_transfer_received') do
            response = client.v2.register_transfer(
              user_id: user_id,
              **transfer_data
            )
            expect(response).to include('externalId')
          end
        end
      end

      context 'when the transfer is withdrawal' do
        let(:transfer_data) do
          {
            network: 'Bitcoin',
            asset: 'BTC',
            transfer_reference: '523c98527ec41c42979e02b9c034f7a92428b658230151cedcaacde7fd8e3800:1QJUiNsNfji6mR1FjAwf6Eg9NxxHPoxpWL',
            direction: 'sent'
          }
        end

        it 'sends a POST request to register a transfer' do
          VCR.use_cassette('v2/register_transfer_sent') do
            response = client.v2.register_transfer(
              user_id: user_id,
              **transfer_data
            )
            expect(response).to include('externalId')
          end
        end
      end
    end

    describe '#register_withdrawal_attempt' do
      let(:withdrawal_data) do
        {
          network: 'Bitcoin',
          asset: 'BTC',
          address: '1QJUiNsNfji6mR1FjAwf6Eg9NxxHPoxpWL',
          attempt_identifier: 'cfbe93a6-0fd7-4c59-aa9b-65bc1ab34586',
          asset_amount: '0.10312309',
          attempt_timestamp: '2025-01-10T00:00:00Z'
        }
      end

      it 'sends a POST request to register a withdrawal attempt' do
        VCR.use_cassette('v2/register_withdrawal_attempt') do
          response = client.v2.register_withdrawal_attempt(
            user_id: user_id,
            **withdrawal_data
          )
          expect(response).to include('externalId')
        end
      end
    end

    describe '#get_transfer' do
      let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

      it 'retrieves transfer information' do
        VCR.use_cassette('v2/get_transfer') do
          response = client.v2.get_transfer(external_id: external_id)
          expect(response).to include('asset', 'network')
        end
      end
    end

    describe '#get_transfer_exposures' do
      let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

      it 'retrieves transfer exposures' do
        VCR.use_cassette('v2/get_transfer_exposures') do
          response = client.v2.get_transfer_exposures(external_id: external_id)
          expect(response).to include('direct')
        end
      end
    end

    describe '#get_transfer_alerts' do
      let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

      it 'retrieves transfer alerts' do
        VCR.use_cassette('v2/get_transfer_alerts') do
          response = client.v2.get_transfer_alerts(external_id: external_id)
          expect(response).to include('alerts')
        end
      end
    end

    describe '#get_transfer_network_identifications' do
      let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

      it 'retrieves transfer network identifications' do
        VCR.use_cassette('v2/get_transfer_network_identifications') do
          response = client.v2.get_transfer_network_identifications(external_id: external_id)
          expect(response).to include('count', 'networkIdentificationOrgs')
        end
      end
    end

    describe '#get_withdrawal_attempt' do
      let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

      it 'retrieves withdrawal attempt information' do
        VCR.use_cassette('v2/get_withdrawal_attempt') do
          response = client.v2.get_withdrawal_attempt(external_id: external_id)
          expect(response).to include('asset', 'network')
        end
      end
    end

    describe '#get_withdrawal_attempt_exposures' do
      let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

      it 'retrieves withdrawal attempt exposures' do
        VCR.use_cassette('v2/get_withdrawal_attempt_exposures') do
          response = client.v2.get_withdrawal_attempt_exposures(external_id: external_id)
          expect(response).to include('direct')
        end
      end
    end

    describe '#get_withdrawal_attempt_alerts' do
      let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

      it 'retrieves withdrawal attempt alerts' do
        VCR.use_cassette('v2/get_withdrawal_attempt_alerts') do
          response = client.v2.get_withdrawal_attempt_alerts(external_id: external_id)
          expect(response).to include('alerts')
        end
      end
    end

    describe '#get_withdrawal_attempt_high_risk_addresses' do
      let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

      it 'retrieves withdrawal attempt high risk addresses' do
        VCR.use_cassette('v2/get_withdrawal_attempt_high_risk_addresses') do
          response = client.v2.get_withdrawal_attempt_high_risk_addresses(external_id: external_id)
          expect(response).to include('chainalysisIdentifications')
        end
      end
    end

    describe '#get_withdrawal_attempt_network_identifications' do
      let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

      it 'retrieves withdrawal attempt network identifications' do
        VCR.use_cassette('v2/get_withdrawal_attempt_network_identifications') do
          response = client.v2.get_withdrawal_attempt_network_identifications(external_id: external_id)
          expect(response).to include('count', 'networkIdentificationOrgs')
        end
      end
    end

    describe '#get_categories' do
      it 'retrieves categories' do
        VCR.use_cassette('v2/get_categories') do
          response = client.v2.get_categories
          expect(response).to include('categories')
        end
      end
    end
  end
end
