const express = require('express')
const cors = require('cors')
import mysql from 'mysql';
const app =express();
const data = require('./data.json');
app.use(cors())
const PORT = process.env.PORT || 3000
const connection = mysql.createConnection({
  host: process.env.RDS_HOSTNAME,
  user: process.env.RDS_USERNAME,
  password: process.env.RDS_PASSWORD,
  port: process.env.RDS_PORT,
  db_name: process.env.RDS_DB_NAME
});
connection.connect()
connection.query(`use ${process.env.RDS_DB_NAME};`)


app.get('/init', async (req, res) => {
  connection.query('CREATE TABLE IF NOT EXISTS users (id INT(5) NOT NULL AUTO_INCREMENT PRIMARY KEY, lastname VARCHAR(40), firstname VARCHAR(40), email VARCHAR(30));');
  connection.query('INSERT INTO users (lastname, firstname, email) VALUES ( "Tony", "Sam", "tonysam@whatever.com"), ( "Doe", "John", "john.doe@whatever.com" );');
  res.send({ message: "init step done" })
})

app.get('/users', async (req, res) => {
  connection.query('SELECT * from users', function (error, results) {
    if (error) throw error;
    res.send(results)
  });
  
})

app.get('/', (req, res) => {
    res.json(data);
});
app.listen(port,()=>{
    console.log('server is running on port:'+port);
})