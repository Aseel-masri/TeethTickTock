const express = require('express');
const session = require('express-session'); // Add this line
const bodyParser = require('body-parser');
const { connectToDB } = require('./db');
const { getAllUsers, getUserById, updateUser, deleteUser, insertUser, getUserByEmailAndPassword } = require('./crud');
const app = express();
const port = process.env.PORT || 8081;
/****************************************************************************** */
const category = require('./categoryModel.js');
const Doctor = require('./doctorModel');
const User = require('./userModel');
const Rating = require('./ratingModel');
const DoctorRequests = require('./RequestModel.js');
const Notification = require('./Notification.js');

const Appointment = require('./appointmentModel');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
app.use(bodyParser.json());
app.use(express.json());
app.use('/profileimg', express.static('profileimg'));
/****************************************************************************** */
app.use(bodyParser.json());
app.use(bodyParser.json());
app.use(express.json());
// Connect to the MongoDB database
connectToDB();
// Routes for CRUD operations
app.get('/users', async (req, res) => {
  const users = await getAllUsers();
  res.json(users);
});

app.get('/users/:id', async (req, res) => {
  const userId = req.params.id;
  const user = await getUserById(userId);
  res.json(user);
});

app.put('/users/:id', async (req, res) => {
  const userId = req.params.id;
  const updatedUserData = req.body;
  const updatedUser = await updateUser(userId, updatedUserData);
  res.json(updatedUser);
});

app.delete('/users/:id', async (req, res) => {
  const userId = req.params.id;
  await deleteUser(userId);
  res.json({ message: 'User deleted successfully' });
});

app.post('/users', async (req, res) => {
  const userData = req.body;
  const newUser = await insertUser(userData);
  res.json(newUser);
});


///////////////////Log in //////////////////////////

app.use(session({
  secret: 'mm',
  resave: false,
  saveUninitialized: true,

}));


app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await getUserByEmailAndPassword(email, password);

  if (user.isUser) {
    req.session.user = user.user;
    console.log('i am user');
    console.log(user.user);
    res.json({ message: 'Login successful', user: user.user, userdoctor: 'user' });
  } else if (user.isDoctor) {
    req.session.user = user.doctor;
    console.log('i am doctor');
    console.log(user.doctor);
    res.json({ message: 'Login successful', user: user.doctor, userdoctor: 'doctor' });
  } else {
    res.status(401).json({ message: 'Invalid email or password' });
  }
});
//*********************************************************************Aseel*********************************************************************************** */

//*********************************************************************Doctors*********************************************************************************** */

app.post("/doctors", async (req, res) => {
  try {
    const newDoctor = new Doctor({
      name: 'Dr. Saleh Arandi',
      email: 'saleh-a53@hotmail.com',
      password: '',
      phoneNumber: '+972 59-434-1882',
      city: 'Nablus',
      locationMap: [32.22219, 35.262191],
      Rating: 0,
      StartTime: '8:00 AM',
      EndTime: '6:00 PM',
      category: '653b617fb20a7b29931645cb',
      WorkingDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday'],
      ProfileImg: 'https://upload.wikimedia.org/wikipedia/commons/6/67/User_Avatar.png',
    });

    const savedDoctor = await newDoctor.save();

    res.status(200).json(savedDoctor);
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
});
app.post("/doctorrequests", async (req, res) => {
  try {
    const categoryy = await category.findOne({ name: req.body.category });
    var catid = "";
    // If the category is found, return its ID
    if (categoryy) {
      catid = categoryy._id;
    } else {
      console.log(`Category with name '${categoryName}' not found.`);
    }
    const newRequest = new DoctorRequests({
      name: req.body.name,
      email: req.body.email,
      password: req.body.password,
      phoneNumber: req.body.password,
      city: req.body.city,
      locationMap: req.body.locationMap,
      category: catid,
    });
    const savedDoctor = await newRequest.save();
    res.status(200).json(savedDoctor);
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
});
const upload = multer({ dest: "./profileimg" });

// Define an endpoint for file upload
app.put('/doctors/changeimage/:doctorId/:x', upload.single('photo'), async (req, res) => {

  try {
    const doctorId = req.params.doctorId;
    const x = req.params.x;

    //print(doctorId);
    const photo = req.file;
    let photoname = 'pic' + x + doctorId + '.png';
    console.log(photoname);
    // print(photoname.toString);
    const photoPath = path.join(__dirname, './profileimg', photoname);

    fs.renameSync(photo.path, photoPath);
    const doctor = await Doctor.findById(doctorId);
    console.log("doctor img is " + doctor.ProfileImg);
    const parts = doctor.ProfileImg.split('/');
    console.log(parts.length);
    const photoTodeletePath = path.join(__dirname, './profileimg', parts[parts.length - 1]);
    if (parts[0] == 'http:') {
      fs.unlinkSync(photoTodeletePath);
      console.log("doctor img path " + photoTodeletePath);
    }
    await Doctor.findByIdAndUpdate(doctorId, { ProfileImg: ("http://192.168.1.105:8081/profileimg/" + photoname) });

    res.status(200).json({ message: "Profile image updated successfully" });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
app.put('/doctors/:doctorId', async (req, res) => {
  try {
    const doctorId = req.params.doctorId;
    const updatedData = req.body;
    const doctor = await Doctor.findByIdAndUpdate(doctorId, updatedData, { new: true });

    if (!doctor) {
      return res.status(404).json({ message: 'Doctor not found' });
    }

    return res.status(200).json(doctor);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});
app.put('/doctors/:doctorId/location', async (req, res) => {
  try {
    const doctorId = req.params.doctorId;
    const newLocationMap = req.body.locationMap;
    const doctor = await Doctor.findByIdAndUpdate(doctorId, { locationMap: newLocationMap }, { new: true });

    if (!doctor) {
      return res.status(404).json({ message: 'Doctor not found' });
    }

    return res.status(200).json(doctor);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});
app.get('/doctors/:doctorId/location', async (req, res) => {
  try {
    const doctorId = req.params.doctorId;

    const doctor = await Doctor.findById(doctorId);

    if (!doctor) {
      return res.status(404).json({ message: 'Doctor not found' });
    }

    const locationMap = doctor.locationMap;

    return res.status(200).json({ locationMap });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});
app.get('/doctors/:doctorId', async (req, res) => {
  try {
    const doctorId = req.params.doctorId;

    const doctor = await Doctor.findById(doctorId);

    if (!doctor) {
      return res.status(404).json({ message: 'Doctor not found' });
    }
    return res.status(200).json({ doctor });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.get('/doctors', async (req, res) => {
  try {

    const doctor = await Doctor.find();

    if (!doctor) {
      return res.status(404).json({ message: 'Doctor not found' });
    }
    return res.status(200).json({ doctor });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});
app.get('/doctorslocation', async (req, res) => {
  try {
    const doctors = await Doctor.find();

    if (doctors.length === 0) {
      return res.status(404).json({ message: 'Doctor not found' });
    }

    const doctorDetails = doctors.map(doctor => ({
      name: doctor.name,
      locationMap: doctor.locationMap,
    }));

    return res.status(200).json({ doctorDetails });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});
app.get('/doctorslocation/:catgid', async (req, res) => {
  try {
    const catgid = req.params.catgid;
    const doctors = await Doctor.find({ category: catgid });

    if (doctors.length === 0) {
      return res.status(404).json({ message: 'Doctor not found' });
    }

    const doctorDetails = doctors.map(doctor => ({
      name: doctor.name,
      locationMap: doctor.locationMap,
    }));
    return res.status(200).json({ doctorDetails });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});
//*********************************************************************Categories*********************************************************************************** */
app.post("/cat", async (req, res) => {

  const category1 = new category({ name: 'Pediatric dentist' });
  const category2 = new category({ name: 'Dental neurologist' });
  const category3 = new category({ name: 'Orthodontist' });

  category1.save();
  category2.save();
  category3.save();

  return res.status(200).json(category1);
});
app.get("/categories/:categoryid", async (req, res) => {
  try {
    const categoryid = req.params.categoryid;
    const categ = await category.findById(categoryid);

    if (!categ) {
      return res.status(404).json({ message: 'category not found' });
    }
    return res.status(200).json({ categ });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

/*************************************mira category to return doctors in the same category********************************/
app.get('/doctors/category/:categoryId', async (req, res) => {
  try {
    const categoryId = req.params.categoryId;

    const doctors = await Doctor.find({ 'category': categoryId });

    if (!doctors || doctors.length === 0) {
      return res.status(404).json({ message: 'No doctors found for the given category' });
    }

    return res.status(200).json({ doctors });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});


//*******************************************************************Rating************************************************************************************* */
/* app.post("/rating/:userid/:doctorid", async (req, res) => {
  try {
    const userid = req.params.userid;
    const doctorid = req.params.doctorid;
   // const value = req.body.value;
    const value = parseInt(req.body.value, 10);

    const newRating = new Rating({
      value: value,
      user: userid,
      doctor: doctorid,

    });
    const ratings = await Rating.find({ doctor: doctorid });
    const totalRating = ratings.reduce((sum, rating) => sum + rating.value, 0);
    const averageRating = Math.round(totalRating / ratings.length);
    const doctor = await Doctor.findByIdAndUpdate(doctorid, { Rating: averageRating }, { new: true });
    const savedRating = await newRating.save();
    res.status(200).json({ 'added': savedRating, 'avgvalue': averageRating });
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
}); */

/*********************************work but mira change to comment  
app.post("/rating/:userid/:doctorid", async (req, res) => {
  try {
    const userid = req.params.userid;
    const doctorid = req.params.doctorid;
    const value = req.body.value;
    //console.log("value is" + value);
    const newRating = new Rating({
      value: value,
      user: userid,
      doctor: doctorid,

    });
    // console.log("1");
    const ratings = await Rating.find({ doctor: doctorid });
    //console.log("2");
    const totalRating = ratings.reduce((sum, rating) => sum + rating.value, 0);
    // console.log("3");
    var averageRating;
    if (ratings.length != 0) {
      averageRating = Math.round(totalRating / ratings.length);

    } else {
      averageRating = value;
    }

    //console.log("4");
    const doctor = await Doctor.findByIdAndUpdate(doctorid, { Rating: averageRating }, { new: true });
    //console.log("5");
    const savedRating = await newRating.save();
    //console.log("6");
    res.status(200).json({ 'added': savedRating, 'avgvalue': averageRating });
    //console.log("7");
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
});
*/
app.post("/rating/:userid/:doctorid", async (req, res) => {
  try {
    const userid = req.params.userid;
    const doctorid = req.params.doctorid;
    const value = req.body.value;
    const comment = req.body.comment; // Extract comment from the request body

    const newRating = new Rating({
      value: value,
      comment: comment, // Save comment in the database
      user: userid,
      doctor: doctorid,
    });

    const ratings = await Rating.find({ doctor: doctorid });
    const totalRating = ratings.reduce((sum, rating) => sum + rating.value, 0);
    var averageRating;

    if (ratings.length !== 0) {
      averageRating = Math.round(totalRating / ratings.length);
    } else {
      averageRating = value;
    }

    const doctor = await Doctor.findByIdAndUpdate(doctorid, { Rating: averageRating }, { new: true });
    const savedRating = await newRating.save();

    res.status(200).json({ 'added': savedRating, 'avgvalue': averageRating });
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
});

app.get("/ratings/:doctorid", async (req, res) => {
  try {
    const doctorid = req.params.doctorid;
    const ratings = await Rating.find({ doctor: doctorid });
    res.status(200).json(ratings);
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
});
/*********************************delete rating mira*************** */
app.delete("/rating/:ratingid", async (req, res) => {
  try {
    const ratingid = req.params.ratingid;

    // Check if the rating exists
    const existingRating = await Rating.findById(ratingid);
    if (!existingRating) {
      return res.status(404).json({ 'status': 'Rating not found' });
    }

    // Delete the rating
    await Rating.findByIdAndDelete(ratingid);

    // Recalculate the average rating
    const ratings = await Rating.find({ doctor: existingRating.doctor });
    const totalRating = ratings.reduce((sum, rating) => sum + rating.value, 0);
    const averageRating = ratings.length !== 0
        ? Math.round(totalRating / ratings.length)
        : 0;

    // Update the doctor's average rating
    const doctor = await Doctor.findByIdAndUpdate(existingRating.doctor, { Rating: averageRating }, { new: true });

    res.status(200).json({ 'status': 'Rating deleted successfully', 'avgvalue': averageRating });
  } catch (error) {
    res.status(400).json({ 'status': error.message });
  }
});


/******************************************************************* */
app.post("/cat", async (req, res) => {

  const category1 = new category({ name: 'Pediatric dentist' });
  const category2 = new category({ name: 'Dental neurologist' });
  const category3 = new category({ name: 'Orthodontist' });

  category1.save();
  category2.save();
  category3.save();

  return res.status(200).json(category1);
});
//*************************************************************USER******************************************************************************************* */


app.put('/users/changeimage/:userId/:x', upload.single('photo'), async (req, res) => {

  try {
    const userId = req.params.userId;
    const x = req.params.x;

    //print(doctorId);
    const photo = req.file;
    let photoname = 'pic' + x + userId + '.png';
    console.log(photoname);
    // print(photoname.toString);
    const photoPath = path.join(__dirname, './profileimg', photoname);

    fs.renameSync(photo.path, photoPath);
    //const doctor = await Doctor.findById(userId);
    const user = await getUserById(userId);
    console.log("User img is " + user.ProfileImg);
    const parts = user.ProfileImg.split('/');
    console.log(parts.length);
    const photoTodeletePath = path.join(__dirname, './profileimg', parts[parts.length - 1]);
    if (parts[0] == 'http:') {
      fs.unlinkSync(photoTodeletePath);
      console.log("doctor img path " + photoTodeletePath);
    }
    await User.findByIdAndUpdate(userId, { ProfileImg: ("http://192.168.1.105:8081/profileimg/" + photoname) });

    res.status(200).json({ message: "Profile image updated successfully" });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
//*********************************************************************Appoinments*********************************************************************************** */
app.post("/appointment/:userid/:doctorid", async (req, res) => {
  try {
    const userid = req.params.userid;
    const doctorid = req.params.doctorid;
    const appointmentTime = req.body.appointmentTime;
    const appointmentDate = req.body.appointmentDate;

    // Check if the user or the doctor already has an appointment at the same time and date
    const existingUserAppointment = await Appointment.findOne({
      user: userid,
      appointmentTime: appointmentTime,
      appointmentDate: appointmentDate,
    });

    const existingDoctorAppointment = await Appointment.findOne({
      doctor: doctorid,
      appointmentTime: appointmentTime,
      appointmentDate: appointmentDate,
    });

    if (existingUserAppointment) {
      return res.status(400).json({ error: 'You already have an appointment at the same time and date.' });
    }

    if (existingDoctorAppointment) {
      return res.status(400).json({ error: 'Doctor already has an appointment at the same time and date.' });
    }

    // Create a new Appointment instance with the provided data
    const appointment = new Appointment({
      appointmentTime: appointmentTime,
      appointmentDate: appointmentDate,
      user: userid,
      doctor: doctorid,
    });

    // Save the appointment to the database
    await appointment.save();

    return res.status(200).json(appointment);
  } catch (error) {
    return res.status(500).json({ error: 'An error occurred while creating the appointment.' });
  }
});

app.post("/getTimes/:doctorid", async (req, res) => {
  try {
    const doctorid = req.params.doctorid;
    const appointmentTime = req.body.appointmentTime;
    const appointmentDate = req.body.appointmentDate;
    // Check if the doctor already has an appointment at the same time and date
    const existingDoctorAppointment = await Appointment.findOne({
      doctor: doctorid,
      appointmentTime: appointmentTime,
      appointmentDate: appointmentDate,
    });
    if (existingDoctorAppointment) {
      return res.status(400).json({ error: 'Doctor already has an appointment at the same time and date.' });
    }
    return res.status(200).json({ error: 'No err' });
  } catch (error) {
    // console.log("reeor is " + error);
    return res.status(500).json({ error: error.message });
  }
});
// Check if the user have any appointment in this doctor
app.post("/appointment/isallowed/:userid/:doctorid", async (req, res) => {
  try {
    const userid = req.params.userid;
    const doctorid = req.params.doctorid;
    console.log("1");
    const existingUserAppointment = await Appointment.findOne({
      user: userid,
      doctor: doctorid,
    });
    console.log("2");

    if (!existingUserAppointment) {
      console.log("3");
      return res.status(400).json({ error: 'You are not allowed to add a rating.' });
    }
    console.log("3");
    return res.status(200).json(existingUserAppointment);

  } catch (error) {
    console.log("4");
    return res.status(500).json({ error: 'An error occurred while creating the appointment.' });
  }
});
/************************************Notification******************************************/
app.post('/Notification', async (req, res) => {
  const userData = req.body;
  const newUser = await Notification.create(userData);;
  res.json(newUser);
});
app.get('/Notification/:useremail', async (req, res) => {
  try {
    const Notifications = await Notification.find({ useremail: req.params.useremail });

    if (Notifications.length === 0) {
      // If no notifications are found for the given userid
      return res.status(404).json({ error: 'Notifications not found' });
    }

    res.status(200).json(Notifications);
  } catch (error) {
    console.error(error);
    res.status(500).send('Internal Server Error');
  }
});
app.get('/NotificationUnread/:useremail', async (req, res) => {

  try {
    const useremail = req.params.useremail;

    // Query the database to get the number of unread messages
    const unreadCount = await Notification.countDocuments({ useremail, read: false });
    await Notification.updateMany({ useremail, read: false }, { read: true });

    res.json({ unreadCount });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }

});

/************************************mira******************************************/
// BookedAppointment page 
//get appoitments depend of userID 
app.get('/appointments/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const userAppointments = await Appointment.find({ user: userId });
    res.status(200).json(userAppointments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
//get appoitments depend of userID  
app.delete('/appointments/:id', async (req, res) => {
  try {
    const appointmentsID = req.params.id;
    const deleteAppointments = await Appointment.findByIdAndDelete(appointmentsID);
    res.status(200).json(deleteAppointments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
app.get("/appointment/:doctorid", async (req, res) => {
  try {
    const doctorid = req.params.doctorid;
    console.log("1");
    const appointments = await Appointment.find({
      doctor: doctorid,
    });
    console.log("2");

    if (!appointments) {
      console.log("3");
      return res.status(400).json({ error: 'There are no appointments' });
    }
    console.log("3");
    return res.status(200).json(appointments);

  } catch (error) {
    console.log("4");
    return res.status(500).json({ error: 'An error occurred while creating the appointment.' });
  }
});
app.get("/getusername/:userid", async (req, res) => {
  try {
    const userid = req.params.userid;
    console.log("1");

    // Find a user by their ID
    const user = await User.findById(userid); // Assuming `User` is your Mongoose model

    console.log("2");

    // If the user is not found, return an error response
    if (!user) {
      console.log("3");
      return res.status(400).json({ error: 'User not found' });
    }

    console.log("3");

    // If the user is found, return their name
    return res.status(200).json(user.name);

  } catch (error) {
    // Log the error for debugging
    console.error("Error:", error);

    // Return a meaningful error response
    return res.status(500).json({ error: 'An error occurred while processing the request.' });
  }
});
app.delete("/appointment/deletebyid/:appointmentid", async (req, res) => {
  try {
    const appointmentid = req.params.appointmentid;
    console.log("1");
    const appointments = await Appointment.findByIdAndDelete(appointmentid);
    console.log("2");

    if (!appointments) {
      console.log("3");
      return res.status(400).json({ error: 'There are no appointments' });
    }
    console.log("3");
    return res.status(200).json(appointments);

  } catch (error) {
    console.log("4");
    return res.status(500).json({ error: 'An error occurred while creating the appointment.' });
  }
});

////////////////////////////////////////////////
const Post = require('./postModel');
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

////////////////////posts ///////////////////////////
app.get('/posts', async (req, res) => {
  try {
    const posts = await Post.find();
    res.json(posts);
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to get a single post by ID
app.get('/posts/:postId', async (req, res) => {
  const postId = req.params.postId;
  try {
    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    res.json(post);
  } catch (error) {
    console.error('Error fetching post by ID:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to add a new post
app.post('/posts', async (req, res) => {
  const { doctorId, doctorName, doctorProfileImg, postContent } = req.body;
  const newPost = new Post({
    doctorId,
    doctorName,
    doctorProfileImg,
    postContent,
    createdAt: new Date(),
  });

  try {
    const savedPost = await newPost.save();
    res.status(201).json(savedPost);
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to update a post by ID
app.put('/posts/:postId', async (req, res) => {
  const postId = req.params.postId;
  const updatedPostData = req.body;

  try {
    const updatedPost = await Post.findByIdAndUpdate(postId, updatedPostData, { new: true });
    if (!updatedPost) {
      return res.status(404).json({ error: 'Post not found' });
    }
    res.json(updatedPost);
  } catch (error) {
    console.error('Error updating post by ID:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to delete a post by ID
app.delete('/posts/:postId', async (req, res) => {
  const postId = req.params.postId;

  try {
    const deletedPost = await Post.findByIdAndDelete(postId);
    if (!deletedPost) {
      return res.status(404).json({ error: 'Post not found' });
    }
    res.json({ message: 'Post deleted successfully' });
  } catch (error) {
    console.error('Error deleting post by ID:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});



