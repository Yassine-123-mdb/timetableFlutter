const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost', // Replace with your database host
  user: 'root',      // Replace with your MySQL username
  password: '',      // Replace with your MySQL password
  database: 'Authjwt', // Replace with your database name
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err.message);
    return;
  }
  console.log('Connected to the database');
});

module.exports = db;
