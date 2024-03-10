const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  doctorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Doctors' },
  doctorName: String,
  doctorProfileImg: String,
  postContent: String,
  createdAt: { type: Date, default: Date.now },
  // Add any other fields you need for posts
});

const Post = mongoose.model('Post', postSchema);

module.exports = Post;
