const mongoose = require('mongoose');

const DoctorRequestsSchema = new mongoose.Schema({
    name: String,
    email: String,
    password: String,
    phoneNumber: String,
    city: String,
    locationMap: {
        type: [Number], 
        index: '2dsphere',
    },
    city: String,
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Categories'
    },
}, { collection: 'DoctorRequests' });

const DoctorRequests = mongoose.model('DoctorRequests', DoctorRequestsSchema);

module.exports = DoctorRequests;
