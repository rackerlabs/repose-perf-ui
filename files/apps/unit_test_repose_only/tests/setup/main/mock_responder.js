var express = require('express');
var app = express();

app.get('/*', function(req, res){
  res.send(200,'hello world');
});

app.post('/*', function(req, res){
  res.send(201,'hello world');
});
app.listen(8080);
