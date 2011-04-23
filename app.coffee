
url = require 'url'
async = require 'async'
{get_address_info} = require './scrape-blockexplorer'



api = (req, res, next) ->
  req.x = url.parse(req.url, true).query
  res.api = (y) ->
    res.writeHead 200, {'Content-Type': 'text/json'}
    res.end JSON.stringify y
  next()


module.exports = (app) ->

  app.get '/api/check-addresses.js', api, (req, res, next) ->
    addrs = req.x.addresses.split ','
    async.map addrs, get_address_info, (err, results) ->
      res.api {
        addresses: results
      }

  app.post '/api/publish-tx.js', api, (req, res, next) ->
    throw new Error "TODO"

