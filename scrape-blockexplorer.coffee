
http = require 'http'
assert = require 'assert'
{readData} = require './util'


exports.get_address_info = (address, callback) ->
  http.get {host:"blockexplorer.com", port:80, path:"/address/#{address}"}, (res) ->
    readData res, (data) ->
      html = data.toString('utf-8')
      callback null, {
        address: address
        outpoints: scrape_address_outpoints(html)
      }


scrape_address_outpoints = (html) ->
  outpoints = []
  
  trs = html.match(/<tr>(.|\n)*?Received: Address(.|\n)*?<\/tr>/g)
  assert.ok trs
  
  for tr in trs
    
    m = tr.match /href="\/tx\/([a-zA-Z0-9]+)#o([0-9]+)"/
    assert.ok m
    hash = m[1]
    n = parseInt m[2], 10
    
    m = tr.match(/Block ([0-9]+)<\/a>/)
    assert.ok m
    block_number = parseInt m[1], 10
    
    m = tr.match /<td>([0-9.]+)<\/td>\n<td>Received/
    assert.ok m
    value_str = m[1]
    
    outpoints.push {
      hash: hash
      n: n
      block_number: block_number
      value_str: value_str
    }
  outpoints

