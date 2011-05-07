
http = require 'http'
assert = require 'assert'
async = require 'async'
{readData} = require './util'


exports.get_unspent_outpoints = (address, callback) ->
  
  http.get {host:"blockexplorer.com", port:80, path:"/address/#{address}"}, (res) ->
    readData res, (data) ->
      [received, sent_transactions] = scrape_address_ledger data.toString 'utf-8'
      
      async.map sent_transactions, tx_input_outpoints, (err, results) ->
        
        # Set of received outpoints
        set = {}
        for row in received
          set[row.outpoint] = row
        
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


scrape_address_ledger = (html) ->
  
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
          outpoint: "#{hash}:#{n}"
          block_number: block_number
          value_str: value_str
        }
      else
        sent_transactions_set[hash] = true
  
  sent_transactions = []
  for own k of sent_transactions_set
    sent_transactions.push k
  
  return [received, sent_transactions]

