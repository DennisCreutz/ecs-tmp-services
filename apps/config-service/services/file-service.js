const path = require('path');
const fs = require('fs');

const LIB_FOLDER = process.env.LIB_FOLDER;

const INTERVALLS = new Map();

const writeLibFile = async (serviceId) => {
  fs.mkdir(LIB_FOLDER + serviceId, { recursive: true }, (err) => {
    if (err) throw err;

    fs.appendFile(path.join(LIB_FOLDER + serviceId, 'lib.txt'),
     Date.now() + '\n', (err) => {
       if (err) throw err;
     });
  });
};

exports.startLibWriter = (serviceId) => {
  const intervalID = setInterval(() => writeLibFile(serviceId), 5000);
  INTERVALLS.set(serviceId, intervalID);
  return intervalID;
};

exports.stopLibWriter = (serviceId) => {
  clearInterval(INTERVALLS.get(serviceId));
  INTERVALLS.delete(serviceId);
};

exports.getLibContent = serviceId => fs.readFileSync(path.join(LIB_FOLDER + serviceId, 'lib.txt'), 'utf8');
