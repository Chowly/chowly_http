# ChowHTTP

## Instantiate Client

```ruby
def client
      @client ||= ChowlyHttp::Client.new(
        app: 'My Application',
        base_url: 'https://api.github.com,
        quick: true, # Returns parsed JSON payload instead of full response object.
        debug: true, # Turns on information about request
        timeout: 60, # Timeout for read / write / connect
        common_headers: { # Headers sent with every request sent through client
          'Authorization': "Bearer #{api_key}",
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      )
    end
```

## Use Client

```
client.post(url: '/v1/repos', payload: {ruby: "hash"}, headers: {"X-Request-Header: "123"})

client.get(url: '/v1/repos', params: {username: "chowly"})
```

Supports `post, get, put, patch, delete`