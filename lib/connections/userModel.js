const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  email: String,
  password: String,
  phoneNumber: String,
  city: String,
  ProfileImg: String
}, {
  collection: "user"
});


module.exports = mongoose.model('user', userSchema);



