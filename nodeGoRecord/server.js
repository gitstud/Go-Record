var express = require('express');
var mongoose = require('mongoose');
var bodyParser = require('body-parser');
var jwt = require('jsonwebtoken');
var path = require('path');
var port = 8000;

var app = express();
app.use(bodyParser.urlencoded({extended:true}));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, './client/static')));
app.use(express.static(path.join(__dirname, './bower_components')));
app.use(express.static(path.join(__dirname, './server/config')));
app.use(express.static(path.join(__dirname, './uploads')));





require('./server/config/mongoose.js');
require('./server/config/routes.js')(app);
app.listen(port, function(){
	console.log("listening on port: ", port)
})