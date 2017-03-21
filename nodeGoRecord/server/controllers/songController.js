var fs = require('fs')
var mongoose = require('mongoose');
var Song = mongoose.model('Song');
var audioConverter = require("audio-converter");
var newPath =  __dirname+'/../../uploads/mp3';
var WaveformData = require('waveform-data')
var User = mongoose.model('User');



module.exports = (function(){
	return {
		featured: function(req, res){
			console.log('getting featured songs');
			Song.find({}, function(err, result){
				if (!err){
					res.json(result)
					
				} else {
					console.log(err)
					res.json({error:"no songs found"})
				}
			})
		},
		getProfileMusic: function(req, res){
			console.log('getting profile music');
			console.log(req.params);
			Song.find({artist_id:req.params.id}, function(err, result){
				if (!err){
					console.log(result)
					res.json(result)
				} else {
					console.log(err);
					res.end()
				}
			})
		}, 
		newLike: function(req, res){
			console.log('Oh i think she likes me');

			User.findOne({email:req.params.userEmail}, function(err, result){

				if (!err){
					var flag = 0
					for (var i = 0; i < result.likes.length; i++){
						if (req.params.songID == result.likes[i]){
							flag = 1
							break
						}
					}
				}
				console.log(flag)
				if (flag == 0){
					console.log("Wtf")
					result.likes.push(req.params.songID)
					result.save(function(err2){
						if (!err2){
							Song.findOne({_id:req.params.songID}, function(err3, result3){
								if (!err3){
									result3.likes += 1;
									result3.save(function(err4){
										if (!err4){
											res.status(200).send('OK');
											res.end()
										}
									})
								}
							})
						}
					})
				} else {
					console.log("user not added to likes/ already likes")
				}
					
				
			})

		},
		getLikes: function(req, res){
			console.log('getting liked songs');
			User.findOne({email:req.params.id}, function(err, result){
				myLikes = []
				if (!err){
					console.log('likes: ', result.likes);
					for (var i = 0; i < result.likes.length; i++){
						Song.findOne({_id:result.likes[i]}, function(err2, result2){
							if (!err2){
								myLikes.push(result2)
								if (myLikes.length == result.likes.length){
									res.status(200).json(myLikes);
								}
							} else {
								console.log(err2);
								res.status(500).send('somethin went wrong gettin likes');
							}
						})
					}
				} else {
					console.log(err);
					res.status(500).send('something else went wrong getting likes');
				}
			})
		},

		listen: function(req, res){
			console.log('getting song');
			console.log(req.params.id)
			Song.findOne({_id:req.params.id}, function(err, result){
				if (!err){
					result.plays+=1
					result.save(function(err2){
						res.sendFile(result.filePath);

						if (err){
							console.log(err2)
						}
					})
					
				} else {
					console.log(err);
					res.json({error:"no song found"});
				}
			})
		},
		getImage: function(req, res){
			console.log('grabbin image')
			Song.findOne({_id:req.params.id}, function(err, result){
				if (!err){
					res.sendFile(result.imagePath);
				} else {
					res.json({totally:'fucked'})
				}
			})
		},


		uploadAudio: function(req, res){
			console.log('uploading file: ', req.files)
			User.findOne({email:req.body.email}, function(err, result){
				console.log(result)

				if (!err){
						result.uploads.push(req.files.songFile[0].filename)
						result.save(function(err3){
							if (err3){
								console.log(err3);
								res.status(404).send('shit broke');
								res.end()
							}
						})
					}
			
				audioConverter(req.files.songFile[0].path, newPath, {progressBar:false}).then(function(){
					var audio = new Song()
					audio.name = req.files.songFile[0].originalname;
					audio.filename = req.files.songFile[0].filename;
					audio.filePath = req.files.songFile[0].path;
					audio.imagePath = req.files.imageFile[0].path;
					audio.plays = 0
					audio.likes = 0
					audio.tags = []
					audio.artist = result.name;
					audio.artist_id = result.email;
					audio.size = req.files.songFile[0].size;
					audio.mimeType = req.files.songFile[0].mimetype;
					audio.encoding = req.files.songFile[0].encoding;

					
					audio.save(function(err2){
						if (!err2){
							console.log(audio.imagePath)
							res.json({upload:'successful'});
						} else {
							console.log(err2);
							res.json({error:'error uploading audio'});
						}
					})
				})



			})
		},
		iosSongUpload: function(req, res){
			console.log('uploading file: ', req.files)
			User.findOne({email:req.params.id}, function(err, result){
				console.log(result)

				if (!err){
						result.uploads.push(req.files.audioFile[0].filename)
						result.save(function(err3){
							if (err3){
								console.log(err3);
								res.status(404).send('shit broke');
								res.end()
							}
						})
					}
			
				audioConverter(req.files.audioFile[0].path, newPath, {progressBar:false}).then(function(){
					var audio = new Song()
					audio.name = req.files.audioFile[0].originalname;
					audio.filename = req.files.audioFile[0].filename;
					audio.filePath = req.files.audioFile[0].path;
					audio.imagePath = req.files.imageFile[0].path;
					audio.plays = 0
					audio.likes = 0
					audio.tags = []
					audio.artist = result.name;
					audio.artist_id = result.email;
					audio.size = req.files.audioFile[0].size;
					audio.mimeType = req.files.audioFile[0].mimetype;
					audio.encoding = req.files.audioFile[0].encoding;

					
					audio.save(function(err2){
						if (!err2){
							console.log(audio.imagePath)
							res.json({upload:'successful'});
						} else {
							console.log(err2);
							res.json({error:'error uploading audio'});
						}
					})
				})



			})
		}
	}
})();







