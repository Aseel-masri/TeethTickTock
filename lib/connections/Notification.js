const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
    useremail: String,
    content: String,
    title: String,
    date: String,
    read: {
        type: Boolean,
        default: false
    }
}, {
    collection: "Notification"
});


module.exports = mongoose.model('Notification', NotificationSchema);



