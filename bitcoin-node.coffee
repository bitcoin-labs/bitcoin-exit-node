
net = require 'net'
{MessageParser, pack_message, inv_for_tx} = require 'bitcoin-library'
{readData} = require './util'


exports.BitcoinNode = class BitcoinNode

  publishTX_via_tx: (data, callback) ->
    @conn.write msg pack_message 'tx', data

  publishTX_via_inv: (data, callback) ->
    k = inv_for_tx(data).toString('base64')
    @db[k] = [data, callback]
    @conn.write msg pack_message 'inv', {inventory: [inv_for_tx(data)]}

  constructor: () ->

    @db = {}
    @conn = net.createConnection 8333, 'localhost'
    p = new MessageParser stream:@conn

    p.on 'command', (name, m) =>
      console.log "Bitcoin message: #{name}"

    p.on 'version', (m) =>
      if m >= 209
        @conn.write pack_message 'verack', {}

    p.on 'getdata', (m) =>
      console.log '**getdata'
      for inv in m.inventory
        k = inv.toString 'base64'
        if @db[k]?
          [data, callback] = @db[k]
          @conn.write pack_message 'tx', data
          callback()

    @conn.on 'connect', () =>
      @conn.write pack_message 'version', {
        version: 32100 # 0.3.21
        services: 1
        timestamp: Math.floor(new Date().getTime())
        addr_me:  {services:1, port:8334, ip:new Buffer [127, 0, 0, 1]}
        addr_you: {services:1, port:8333, ip:new Buffer [127, 0, 0, 1]}
        nonce: new Buffer [1, 2, 3, 4, 5, 6, 7, 8]
        sub_version_num: ""
        start_height: 0
      }

