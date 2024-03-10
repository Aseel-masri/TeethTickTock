// const mongoose = require('mongoose');
// const ratingSchema = new mongoose.Schema({
//     value:{
//         type: Number, 
//         default: 0, 
//     } ,
//     user: {
//         type: mongoose.Schema.Types.ObjectId,
//         ref: 'user'
//     },
//     doctor: {
//         type: mongoose.Schema.Types.ObjectId,
//         ref: 'Doctors',
//     }

// }, { collection: 'rating' });

// const Rating = mongoose.model('rating', ratingSchema);

// module.exports = Rating;
const mongoose = require('mongoose');
const ratingSchema = new mongoose.Schema({
  value: {
    type: Number,
    default: 0,
  },
  comment: { // Add comment field to the schema
    type: String,
    default: '', // You can set a default value if needed
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'user',
  },
  doctor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctors',
  }
}, { collection: 'rating' });

const Rating = mongoose.model('rating', ratingSchema);
module.exports = Rating;