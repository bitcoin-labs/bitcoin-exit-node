
express = require 'express'

app = express.createServer()

app.configure () ->
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use app.router
#    app.use express.errorHandler()

require('./app')(app)

app.listen 8000

