
express = require 'express'

app = express.createServer()

require('./app')(app)

app.listen 8000

