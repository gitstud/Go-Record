var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var userSchema = new mongoose.Schema({
	email: {
		type: String,
		required: true,
		validate: [{
			validator: function (email) {
				var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
				return re.test(email);
			},
			message: "{ VALUE } is not a valid email"
		}]
	},
	password: {
		type: String,
		required: true,
		minlength: 3
	},
	name:String,
	uploads:Array,
	likes:Array,
	plays:Number,
	tags:Array,
	following:Array,
	followers:Array,
	location:String,
	imagePath:String,
	blocked:Array,
	pageViews:Number,

}, {timestamps:true});

mongoose.model('User', userSchema);