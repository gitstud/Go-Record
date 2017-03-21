var bcrypt = require('bcryptjs');
var mongoose = require('mongoose');
var User = mongoose.model('User');

module.exports = (function(){
	return {
		getArtist: function(req, res){
			console.log('getting artist profile');
			User.findOne({email:req.params.id}, function(err, result){
				if (!err){
					res.json(result)
				} else {
					console.log(err);
					res.end()
				}
			})
		},
		iosProfileImage: function(req, res){
			User.findOne({email:req.params.id}, function(err, result){
				result.imagePath = req.files.imageFile[0].path
				result.save(function(err2){
					if (err2){
						console.log(err2)
					}
				})
			})
		},

		getImage: function(req, res){
			console.log('grabbin image')
			User.findOne({email:req.params.id}, function(err, result){
				if (!err){
					res.sendFile(result.imagePath);
				} else {
					res.json({totally:'fucked'})
				}
			})
		},

		addFollower: function(req, res){

			var flag = 0;

			console.log('adding Follower', req.params);
			User.findOne({email:req.params.newFollow}, function(err, result){
				if (!err){ 
					for (var j = 0; j < result.followers.length; j++){
						console.log("followers", result.followers[j]);
						if (result.followers[j] == req.params.loggedUser){
							flag++;
						}
					}
					if (flag == 0){
						result.followers.push(req.params.loggedUser);
						result.save(function(err4){
							if (!err4){
								User.findOne({email:req.params.loggedUser}, function(err2, result2){
									if(!err2){
										result2.following.push(req.params.newFollow);
										result2.save(function(err3){
											if (!err3){
												console.log(result2.following)
												res.json({});
											}
										})
									} else {
										console.log(err2);
										res.end()
									}
								})
							} else {
								console.log(err4)
								res.end()
							}
						});
					} else {
						console.log('already following');
						res.end()
					}
				} else {
					console.log(err);
					res.end()
				}
			})
		},

		whoIFollow: function(req, res){
			console.log('getting the people I follow');
			User.findOne({email:req.params.id}, function(err, result){
				console.log(result.following)
				if (!err){
					var myFollows = []
					for (var i = 0; i < result.following.length; i++){
						console.log('myFollows loop ', result.following[i])
						User.findOne({email:result.following[i]}, function(err2, result2){
							if (!err){
								
								myFollows.push(result2)
								if (myFollows.length == result.following.length){
									console.log("myFollows", myFollows)
									res.json(myFollows)
									res.end()
								}
								
							} else {
								console.log(err2);
							}
						})
					}
					
				} else {
					console.log(err);
					res.end()
				}
			})
		},
		getMyFollowers: function(req, res){
			console.log('getting my followers');
			User.findOne({email:req.params.id}, function(err, result){
				if (!err){
					var myFollows = []
					for (var i = 0; i < result.followers.length; i++){
						User.findOne({email:result.followers[i]}, function(err2, result2){
							if (!err){
								myFollows.push(result2)
								console.log('my Follower ', myFollows)
								if (myFollows.length == result.followers.length){
									console.log("success")
									res.json(myFollows)
								}
							} else {
								console.log(err2);
								res.json(myFollows)
								res.end()
							}
						})
					}
					console.log("$$$$$$", myFollows)
				} else {
					console.log(err);
					res.end()
				}
			})
		},

		register: function(req, res){
			console.log('registering user', req.body)
			User.findOne({email: req.body.email}, function(err, result){
				if (err){
					console.log('error registering: ', error)
					res.json({})
				} else if (result) {
					console.log('email is already registered')
					res.json({})
				} else {
					var hash = bcrypt.hashSync(req.body.password, bcrypt.genSaltSync(8));
					var user = new User({email:req.body.email, password: hash});
					user.name = req.body.name;
					user.uploads = [];
					user.likes = [];
					user.plays = 0;
					user.tags = [];
					user.following = [];
					user.followers = [];
					user.location = '';
					user.imagePath = '';
					user.blocked = [];
					user.pageViews = 0;
					

					user.save(function(err){
						if (!err){
							res.json({});
						} else {
							console.log(err)
						}
					})
				}
			})
		},
		login: function(req, res){
			console.log('logging user');
			User.findOne({email: req.body.email}, function(err, oneUser){
				if (!err){
					if (oneUser){
						console.log("user email found");
						bcrypt.compare(req.body.password, oneUser.password, function(err, match){
							if (match){
								console.log("passwords match");
								res.json({})
							} else {
								console.log("passwords do not match");
								res.json({})
							}
						})
					} else {
						console.log("user not found")
					}
				} else {
					console.log('error: ', error)
				}
			})
		}
	}
})();