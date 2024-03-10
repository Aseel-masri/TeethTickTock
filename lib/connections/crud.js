const mongoose = require('mongoose');

// const user = require('./userModel').default;
const user = require('./userModel');
const doctor = require('./doctorModel');
const Appointment = require('./appointmentModel');


// Function to get all users
const getAllUsers = async () => {
  return user.find();
};

// Function to get user by ID
const getUserById = async (userId) => {
  return user.findById(userId);
};

// Function to update user data
const updateUser = async (userId, updatedUserData) => {
  return user.findByIdAndUpdate(userId, updatedUserData, { new: true });
};

// Function to delete user
const deleteUser = async (userId) => {
  return user.findByIdAndDelete(userId);
};

// Function to insert a new user
const insertUser = async (userData) => {
  return user.create(userData);
};

const getUserByEmailAndPassword = async (email, password) => {
  const foundUser = await user.findOne({ email, password });
  const foundDoctor = await doctor.findOne({ email, password });

  if (foundUser) {
    return { user: foundUser, isUser: true, isDoctor: false };
  } else if (foundDoctor) {
    return { doctor: foundDoctor, isUser: false, isDoctor: true };
  }

  return { isUser: false, isDoctor: false };
};

// const deleteAppointment = async (AppointmentID) => {
//   return Appointment.findByIdAndDelete(AppointmentID);
// };

module.exports = { getAllUsers, getUserById, updateUser, deleteUser, insertUser, getUserByEmailAndPassword};
