

exports.joinBuffers = joinBuffers = (arr) ->
  size = 0
  for x in arr
    size += x.length
  result = new Buffer size
  pos = 0
  for x in arr
    x.copy result, pos
    pos += x.length
  result


exports.readData = readData = (s, callback) ->
  chunks = []
  s.on 'data', (data) -> chunks.push data
  s.on 'end', () -> callback joinBuffers chunks

