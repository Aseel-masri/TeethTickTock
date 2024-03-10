const mongoose = require('mongoose');

const mongoURI = 'mongodb+srv://mirajamous:v2h60guaintqqggQ@toothticktock.yey0gqw.mongodb.net/ToothTickTockdb';

const connectToDB = async () => {
  try {
    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Connected to MongoDB Atlas');
  } catch (err) {
    console.error('Error connecting to MongoDB Atlas:', err);
  }
};

module.exports = { connectToDB };
