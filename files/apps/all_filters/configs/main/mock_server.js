var express = require('express');
var zlib = require('zlib');

var app = express();

app.get('/*', function(req, res){
  res.writeHead(200, {'Content-Type':'text/html', 'Content-Encoding': 'gzip'});
  var text = 'hello world';
  zlib.gzip(text, function(_, result){
    res.end(result);
  });
});

app.post('/*', function(req, res){
  res.send(201,'hello world');
});
app.listen(8080);
