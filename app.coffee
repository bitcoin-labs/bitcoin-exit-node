
url = require 'url'
async = require 'async'
{get_unspent_outpoints} = require './scrape-blockexplorer'
{BitcoinNode} = require './bitcoin-node'


CONNECT_TO_BITCOIND = true


if CONNECT_TO_BITCOIND
  bitcoin_node = new BitcoinNode



api = (req, res, next) ->
  console.log "[REQ] #{req.url}"
  req.x = url.parse(req.url, true).query
  res.api = (y) ->
    res.writeHead 200, {'Content-Type': 'text/json'}
    res.end JSON.stringify y
  next()


module.exports = (app) ->

  app.get '/api/unspent-outpoints.js', api, (req, res, next) ->
    addrs = req.x.addresses.split ','
    async.map addrs, get_unspent_outpoints, (err, results) ->
      unspent_outpoints = []
      for arr in results
        for x in arr
          unspent_outpoints.push x
      res.api {
        unspent_outpoints: unspent_outpoints
      }

  if CONNECT_TO_BITCOIND
    app.post '/api/publish-tx.js', api, (req, res, next) ->
      tx = new Buffer req.body.tx64, 'base64'
      bitcoin_node.publishTX_via_tx tx, () ->
        res.api {}
