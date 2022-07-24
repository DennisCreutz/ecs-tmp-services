const express = require('express');
const path = require('path');
const fs = require('fs');

const LIB_FOLDER = process.env.LIB_FOLDER;
const SERVICE_ID = process.env.SERVICE_ID;

const app = express();
const port = 3000;

console.log('Start to watch file...');
fs.watchFile(
 // The name of the file to watch
 path.join(LIB_FOLDER, 'lib.txt'),

 // The options parameter is used to
 //modify the behaviour of the method
 {
   // Specify the use of big integers
   // in the Stats object
   bigint: false,

   // Specify if the process should
   // continue as long as file is
   // watched
   persistent: true,

   // Specify the interval between
   // each poll the file
   interval: 5000,
 },
 (curr, prev) => {
   console.log('\nThe file was edited');

   // Show the time when the file was modified
   console.log('Previous Modified Time', prev.mtime);
   console.log('Current Modified Time', curr.mtime);

   console.log(
    'The contents of the current file are:',
    fs.readFileSync(path.join(LIB_FOLDER, 'lib.txt'), 'utf8')
   );
 }
);

app.get('/', (req, res) => {
  res.send('Healthy');
});

app.get('/tmp*', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);

  console.log(JSON.stringify(fs.readFileSync(path.join(LIB_FOLDER, 'lib.txt'), 'utf8')));
});
