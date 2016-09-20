# Recent Purchases API

A sample API for querying the recent purchases of a user, which other users also bought those products,
and sorts them by the most frequently purchased.

## Install and run server

- `bundle`
- `ruby app.rb`

The API will be running on the default port `3000`.

## Tests

- `rspec spec.rb`

## API Reference

### GET recent_purchases/:username

- params:
  - username (string)

- response:
```
[
  {
    "id":187478,
    "face":"༼ ºل͟º ༽",
    "price":462,
    "size":20,
    "recent":[
      {
        "id":941573,
        "username":
        "Morgan_Barton",
        "productId":187478,
        "date":"2016-08-31T08:22:12.081Z"
      },
      ...
    ]
  },
  ...
]
```
