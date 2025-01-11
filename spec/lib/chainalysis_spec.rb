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
        VCR.use_cassette('register_transfer_received') do
          response = client.register_transfer(
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
        VCR.use_cassette('register_transfer_sent') do
          response = client.register_transfer(
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
      VCR.use_cassette('register_withdrawal_attempt') do
        response = client.register_withdrawal_attempt(
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
      VCR.use_cassette('get_transfer') do
        response = client.get_transfer(external_id: external_id)
        expect(response).to include('asset', 'network')
      end
    end
  end

  describe '#get_transfer_exposures' do
    let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

    it 'retrieves transfer exposures' do
      VCR.use_cassette('get_transfer_exposures') do
        response = client.get_transfer_exposures(external_id: external_id)
        expect(response).to include('direct')
      end
    end
  end

  describe '#get_transfer_alerts' do
    let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

    it 'retrieves transfer alerts' do
      VCR.use_cassette('get_transfer_alerts') do
        response = client.get_transfer_alerts(external_id: external_id)
        expect(response).to include('alerts')
      end
    end
  end

  describe '#get_transfer_network_identifications' do
    let(:external_id) { '9a78cde9-890c-3563-8f24-2b99fcb96409' }

    it 'retrieves transfer network identifications' do
      VCR.use_cassette('get_transfer_network_identifications') do
        response = client.get_transfer_network_identifications(external_id: external_id)
        expect(response).to include('count', 'networkIdentificationOrgs')
      end
    end
  end

  describe '#get_withdrawal_attempt' do
    let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

    it 'retrieves withdrawal attempt information' do
      VCR.use_cassette('get_withdrawal_attempt') do
        response = client.get_withdrawal_attempt(external_id: external_id)
        expect(response).to include('asset', 'network')
      end
    end
  end

  describe '#get_withdrawal_attempt_exposures' do
    let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

    it 'retrieves withdrawal attempt exposures' do
      VCR.use_cassette('get_withdrawal_attempt_exposures') do
        response = client.get_withdrawal_attempt_exposures(external_id: external_id)
        expect(response).to include('direct')
      end
    end
  end

  describe '#get_withdrawal_attempt_alerts' do
    let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

    it 'retrieves withdrawal attempt alerts' do
      VCR.use_cassette('get_withdrawal_attempt_alerts') do
        response = client.get_withdrawal_attempt_alerts(external_id: external_id)
        expect(response).to include('alerts')
      end
    end
  end

  describe '#get_withdrawal_attempt_high_risk_addresses' do
    let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

    it 'retrieves withdrawal attempt high risk addresses' do
      VCR.use_cassette('get_withdrawal_attempt_high_risk_addresses') do
        response = client.get_withdrawal_attempt_high_risk_addresses(external_id: external_id)
        expect(response).to include('chainalysisIdentifications')
      end
    end
  end

  describe '#get_withdrawal_attempt_network_identifications' do
    let(:external_id) { 'f226edb0-675e-3072-9392-6082033979b4' }

    it 'retrieves withdrawal attempt network identifications' do
      VCR.use_cassette('get_withdrawal_attempt_network_identifications') do
        response = client.get_withdrawal_attempt_network_identifications(external_id: external_id)
        expect(response).to include('count', 'networkIdentificationOrgs')
      end
    end
  end

  describe '#get_categories' do
    it 'retrieves categories' do
      VCR.use_cassette('get_categories') do
        response = client.get_categories
        expect(response).to include('categories')
      end
    end
  end
end
