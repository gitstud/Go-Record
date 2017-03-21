console.log('Routes up');
var mongoose = require('mongoose');
var multer = require('multer')
var Wave = require('waveform-data')
var fs = require('fs')

console.log(__dirname)
var userController = require('../controllers/users.js');
var songController = require('../controllers/songController.js');

module.exports = function(app){
	app.post('/newUser', function(req, res){
		console.log('register in process');
		userController.register(req, res);
	});
	app.post('/login', function(req, res){
		userController.login(req, res);
	});
	app.get('/uploadSong', function(req, res){
		songController.newSong(req, res);
	});
	app.get('/featured', function(req, res){
		songController.featured(req, res);
	});
	app.post('/uploadSong', multer({dest: __dirname+'/../../uploads/songs'}).fields([{name:'songFile', maxCount:1}, {name:'imageFile', maxCount:1}, {name:'email', maxCount:1}]), function(req, res){
		console.log(req.files);
		songController.uploadAudio(req, res);
	});
	app.get('/requestAudio/:id', function(req, res){
		console.log('hitting the route?')
		console.log(req.param('id'))
		songController.listen(req, res);
	});
	app.get('/imageFor/:id', function(req, res){
		songController.getImage(req, res);
	})
	app.get('/waveform/:id', function(req, res){
		res.set('Content-Type', 'application/json');
		console.log(res.header)
		path = __dirname+'/../../uploads/songs/'
		fs.createReadStream(path+req.params.id).pipe(res);
	})
	app.get('/artist/:id', function(req, res){
		console.log(req.params)
		userController.getArtist(req, res);
	})
	app.get('/profile_music/:id', function(req, res){
		songController.getProfileMusic(req, res);
	})
	app.get('/following/:id', function(req, res){
		userController.whoIFollow(req,res);
	})
	app.get('/followers/:id', function(req, res){
		userController.getMyFollowers(req, res);
	})
	app.get('/newFollower/:loggedUser/:newFollow', function(req, res){
		userController.addFollower(req, res);
	})
	app.get('/favorites/:id', function(req, res){
		songController.getLikes(req, res);
	})
	app.get('/likeSong/:userEmail/:songID', function(req, res){
		console.log(req.params)
		songController.newLike(req, res);
	})
	app.post('/iosUpload/:id', multer({dest: __dirname+'/../../uploads/songs'}).fields([{name:'audioFile', maxCount:1}, {name:'imageFile', maxCount:1}]), function(req, res){
		console.log(req.params.id)
		console.log(req.files);
		songController.iosSongUpload(req, res);
		res.status(200)
	})
	app.post('/iosProfileImage/:id', multer({dest: __dirname+'/../../uploads/songs'}).fields([{name:'imageFile', maxCount:1}]), function(req, res){
		console.log(req.params.id)
		console.log(req.files);
		userController.iosProfileImage(req, res);
		res.status(200)
	})
	app.get('/getProfileImage/:id', function(req, res){
		userController.getImage(req, res);
	})

	app.post('*', function(req, res){
		console.log("post misfire");
		console.log(req)
	})
	app.get('*', function(req, res){
		console.log('get misfire')
	})

};