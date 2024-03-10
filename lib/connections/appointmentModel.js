const mongoose = require('mongoose');

const AppointmentSchema = new mongoose.Schema({
    appointmentTime: String,
    appointmentDate: String,
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user'
    },
    doctor: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctors'
    },


    ProfileImg: String,
}, { collection: 'Appointment' });

const Appointment = mongoose.model('Appointment', AppointmentSchema);

module.exports = Appointment;
