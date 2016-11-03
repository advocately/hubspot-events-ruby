# Hubspot Events

A ruby client for the [Hubspot](https://www.hubspot.com/) [HTTP API](http://help.hubspot.com/developer-docs/http-api).

## Installation

Add this line to your application's Gemfile:

    gem 'hubspot-events-ruby', github: 'advocately/hubspot-events-ruby'

And then execute:

    $ bundle

Or install it yourself:

    $ gem install https://github.com/advocately/hubspot-events-ruby

## Usage

### Before we get started: API client vs. JavaScript snippet

It's helpful to know that everything below can also be accomplished
through the [Hubspot JavaScript snippet](http://help.hubspot.com/developer-docs/javascript-sdk).

### Setup

Create an instance of the client with your [hubspot](https://www.hubspot.com/) organization id. You'll have to ask the support team what your ORG ID is.

```ruby
hubspot = HubspotEvents::Client.new("YOUR ORG ID")
```

### Identify a user

```ruby
# Arguments
# attributes (required) - a hash of information about the customer. You can pass any
#                         information that would be useful in your triggers. You 
#                         must at least pass in an id, email, and created_at timestamp.

hubspot.identify(5,  {
  email: "bob@example.com",
  created_at: customer.created_at.to_i,
  first_name: "Bob",
  plan: "basic"
})
```

### Tracking an event

```ruby
# Arguments
# user_id (required) - the id of the customer who you want to associate with the event.
# name (required)        - the name of the event you want to track.
# attributes (optional)  - any related information you'd like to attach to this
#                          event. These attributes can be used in your triggers to control who should
#                          receive the triggered email. You can set any number of data values.

hubspot.track(5, "purchase", { type: "socks", price: "13.99" })
```

**Note:** If you'd like to track events which occurred in the past, you can include a `created_at` attribute
(in seconds since the epoch), and we'll use that as the date the event occurred.

```ruby
hubspot.track(5, "purchase", type: "socks", price: "13.99", created_at: 1365436200)
```

## Contributing

1. Fork it
2. Clone your fork (`git clone git@github.com:MY_USERNAME/hubspot-ruby.git && cd hubspot-ruby`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
