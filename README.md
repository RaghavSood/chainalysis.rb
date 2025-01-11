# Chainalysis Ruby Client

A Ruby wrapper for the Chainalysis Transaction Monitoring API. This client library provides a simple, intuitive interface to interact with Chainalysis's API services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chainalysis'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install chainalysis
```

## Usage

First, initialize a client with your API key:

```ruby
require 'chainalysis'

client = Chainalysis::Client.new(api_key: 'your_api_key')
```

### Registering a Transfer

```ruby
# Register a new transfer
response = client.register_transfer(
  user_id: 'user123',
  network: 'Bitcoin',
  asset: 'BTC',
  transfer_reference: 'tx_hash:address',
  direction: 'received',
  # Optional parameters
  transfer_timestamp: '2024-01-10T15:30:00Z',
  asset_amount: 1.5,
  asset_price: 45000.00,
  asset_denomination: 'USD'
)

# The response includes an externalId that you can use to query the transfer
external_id = response['externalId']
```

### Managing Transfers

```ruby
# Get transfer details
transfer = client.get_transfer(external_id: 'transfer_external_id')

# Get transfer exposures
exposures = client.get_transfer_exposures(external_id: 'transfer_external_id')

# Get transfer alerts
alerts = client.get_transfer_alerts(external_id: 'transfer_external_id')

# Get transfer network identifications
identifications = client.get_transfer_network_identifications(external_id: 'transfer_external_id')
```

### Managing Withdrawal Attempts

```ruby
# Register a withdrawal attempt
response = client.register_withdrawal_attempt(
  user_id: 'user123',
  network: 'Bitcoin',
  asset: 'BTC',
  address: '1EM4e8eu2S2RQrbS8C6aYnunWpkAwQ8GtG',
  attempt_identifier: 'withdrawal_001',
  asset_amount: 2.5,
  attempt_timestamp: '2024-01-10T15:30:00Z'
)

# Get withdrawal attempt details
withdrawal = client.get_withdrawal_attempt(external_id: 'withdrawal_external_id')

# Get withdrawal attempt exposures
exposures = client.get_withdrawal_attempt_exposures(external_id: 'withdrawal_external_id')

# Get withdrawal attempt alerts
alerts = client.get_withdrawal_attempt_alerts(external_id: 'withdrawal_external_id')

# Get high risk addresses
addresses = client.get_withdrawal_attempt_high_risk_addresses(external_id: 'withdrawal_external_id')

# Get network identifications
identifications = client.get_withdrawal_attempt_network_identifications(external_id: 'withdrawal_external_id')
```

### Categories and Administration

```ruby
# Get all categories
categories = client.get_categories

# Get internal users (requires ORGADMIN permission)
users = client.get_internal_users
```

## Error Handling

The client includes custom error classes for different types of API errors:

```ruby
begin
  client.get_transfer(external_id: 'invalid_id')
rescue Chainalysis::NotFoundError => e
  puts "Transfer not found: #{e.message}"
rescue Chainalysis::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Chainalysis::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
rescue Chainalysis::BadRequestError => e
  puts "Bad request: #{e.message}"
rescue Chainalysis::ApiError => e
  puts "API error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

```bash
$ bundle exec rspec
```

Tests use VCR to record and replay HTTP interactions. To record new interactions, delete the corresponding cassette file and run the tests.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chainalysis Ruby Client project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).