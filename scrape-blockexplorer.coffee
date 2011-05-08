
http = require 'http'
assert = require 'assert'
async = require 'async'
{readData} = require './util'


exports.get_unspent_outpoints = (address, callback) ->
  
  http.get {host:"blockexplorer.com", port:80, path:"/address/#{address}"}, (res) ->
    readData res, (data) ->
      html = data.toString 'utf-8'
      [received, sent_transactions] = scrape_address_ledger html, address
      
      async.map sent_transactions, tx_input_outpoints, (err, results) ->
        
        # Set of received outpoints
        set = {}
        for row in received
          set["#{row.hash}:#{row.n}"] = row
        
        # Setminus the spent ones
        for outpoints in results
          for outpoint in outpoints
            delete set[outpoint]
        
        unspent_outpoints = []
        for own k, v of set
          unspent_outpoints.push v
        
        callback null, unspent_outpoints


tx_input_outpoints = (tx_hash, cb) ->
  http.get {host:"blockexplorer.com", port:80, path:"/tx/#{tx_hash}"}, (res) ->
    readData res, (data) ->
      html = data.toString 'utf-8'
      
      rg = /<td><a name="i[0-9]+" href="\/tx\/([0-9a-fA-F]+)#o([0-9]+)"/g
      r  = /<td><a name="i[0-9]+" href="\/tx\/([0-9a-fA-F]+)#o([0-9]+)"/
      
      outpoints = []
      for text in html.match rg
        m = text.match r
        outpoints.push "#{m[1]}:#{m[2]}"
      
      cb null, outpoints


satoshis_from_decimal = (text) ->
  if text.match /^[0-9]+$/
    parseInt(text, 10) * 1e8
  else
    [left, right] = text.split '.'
    assert.ok (right.length <= 8), "right.length > 8"
    rightSatoshis = parseInt(right, 10) * Math.pow(10, 8 - right.length)
    (left * 1e8) + rightSatoshis

scrape_address_ledger = (html, address) ->
  
  received = []
  sent_transactions_set = {}
  
  trs = html.match /<tr>(.|[\r\n])*?<\/tr>/g
  assert.ok trs
  
  for tr in trs
    amount_match = tr.match /<td>([0-9.]+)<\/td>[ \t\r\n]*<td>(Received|Sent)/
    if amount_match
      
      m = tr.match /href="\/tx\/([a-zA-Z0-9]+)#.([0-9]+)"/
      assert.ok m, 'hash, n'
      hash = m[1]
      n = parseInt m[2], 10
      
      m = tr.match /Block ([0-9]+)<\/a>/
      assert.ok m, 'block_number'
      block_number = parseInt m[1], 10
      
      value_str = amount_match[1]
      
      if tr.match /Received/
        received.push {
          hash: hash
          n: n
          satoshis: satoshis_from_decimal(value_str)
          amount: value_str
          address: address
        }
      else
        sent_transactions_set[hash] = true
  
  sent_transactions = []
  for own k of sent_transactions_set
    sent_transactions.push k
  
  return [received, sent_transactions]

