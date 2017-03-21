// var mongoose = require('mongoose');
// var Schema = mongoose.Schema;
// //mongoose.connect('mongodb://localhost/gridFS');
// var conn = mongoose.connection;
// var path = require('path');
// var Grid = require('gridfs-stream');
// var fs = require('fs');
// Grid.mongo = mongoose.mongo;
// console.log('saving song')
// var songPath = path.join(__dirname, '../controllers/uploads/songs/Master.wav')


// conn.once('open', function(){
// 	console.log('- connection open -');
// 	var gfs = Grid(conn.db);
// 	var writeStream = gfs.createWriteStream({
// 		filename: 'big.wav'
// 	})

// 	fs.createReadStream(songPath).pipe(writeStream);

// 	writeStream.on('close', function(file){
// 		console.log(file.filename + ' Written to DB');
// 	})


// })




var mongoose = require('mongoose');
var songSchema = new mongoose.Schema({
	name:String,
	filename:String,
	filePath:String,
	imagePath:String,
	plays:Number,
	likes:Number,
	tags:Array,
	artist:String,
	artist_id:String,
	size:Number,
	mimeType:String,
	encoding:String,
	waveForm:String
}, {timestamps:true});

mongoose.model('Song', songSchema);













