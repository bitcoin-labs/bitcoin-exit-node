

## API

### publish-tx
<pre>
POST /api/publish-tx.js
  tx64=...

--> {"ok": true}
</pre>


### get-address-info
<pre>
GET /api/get-address-info.js?addresses= (comma-separated base58 addresses)

--> {
  "addresses": [
    {
      "address": "...",
      "outpoints": [
        {
          hash: 
          n: 
          value: 
        },
        ...
      ]
    }
  ]
}
</pre>
