const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: String,
  
},{ collection: 'Categories' });

const Category = mongoose.model('Categories', categorySchema);

module.exports = Category;
