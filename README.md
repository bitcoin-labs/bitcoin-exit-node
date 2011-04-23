

## API

### publish-tx
<pre>
Note: Content-Type must be "application/x-www-form-urlencoded" or "application/json"

POST /api/publish-tx.js
  tx64=...

--> {"ok": true}
</pre>


### get-address-info
<pre>
GET /api/check-addresses.js?addresses= (comma-separated base58 addresses)

--> {
  "addresses": [
    {
      "address": "...",
      "outpoints": [
        {
          hash: 
          n: 
          block_number: 
          value_str:
        },
        ...
      ]
    }
  ]
}
</pre>
