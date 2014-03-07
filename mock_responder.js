var express = require('express');
var app = express();
app.use (function(req, res, next) {
    var data='';
    req.setEncoding('utf8');
    req.on('data', function(chunk) { 
       data += chunk;
    });

    req.on('end', function() {
        req.body = data;
        next();
    });
});

app.get('/*', function(req, res){
  res.send(200,'hello world');
});

app.put('/*', function(req,res){
  res.set('content-type', 'application/xml');
  res.set('x-pp-user', 'user1');
  res.send(201,'<a><remove-me>test</remove-me>Stuff</a>');
});

app.del('/*', function(req, res){
    res.send(204,'hello world');
});

app.post('/*', function(req, res){
    res.send(201,'hello world');
});
app.listen(8080);
