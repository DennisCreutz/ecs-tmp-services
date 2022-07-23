const express = require('express');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const { insertTmpService, invokeLambda } = require('./services/mysql-service');
const { startLibWriter, stopLibWriter, printIntervals, getLibContent } = require('./services/file-service');

const app = express();
const port = 3000;

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.post('/config', async (req, res) => {
  let result;

  const body = req.body;
  const userId = body.user;

  if (userId) {
    const serviceId = crypto.randomUUID().replaceAll('-', '');
    const currDateTime = parseJSDateToMySqlDate(new Date());
    const lambdaARN = process.env.CONFIG_SERVICE_ARN;

    console.log(`Executing query for user ${userId}, service ${serviceId} and timestamp ${currDateTime}`);
    result = await insertTmpService(userId, serviceId, currDateTime);
    console.log(`Result: ${result}`);

    console.log(`Invoking Lambda function ${lambdaARN}`);
    const invokeResult = await invokeLambda(lambdaARN, {
      userId,
      serviceId,
      currDateTime
    });
    console.log(`Invoke Lambda result: ${JSON.stringify(invokeResult)}`);

    console.log('Starting Lib. writer...');
    const intervalId = startLibWriter(serviceId);
    console.log(`Started Lib. writer with interval ID: ${intervalId}`);
  } else {
    result = 'No userId';
  }

  res.send(JSON.stringify(result));
});

app.get('/config/:serviceId', async (req, res) => {
  const serviceId = req.params.serviceId;
  console.log(`Getting Lib. content for serviceId ${serviceId}...`);
  const libContent = getLibContent(serviceId);
  res.send(JSON.stringify(libContent));
});

app.delete('/config/:serviceId', async (req, res) => {
  const serviceId = req.params.serviceId;
  console.log(`Stopping Lib. writer with serviceId ${serviceId}...`);
  stopLibWriter(serviceId);
  res.send('Done');
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});


const parseJSDateToMySqlDate = (jsDate = null) => {
  if (jsDate == null) {
    return null;
  }

  let date;
  if (typeof jsDate === 'string') {
    date = new Date(jsDate);
  } else {
    date = jsDate;
  }

  return date.toISOString().slice(0, 19).replace('T', ' ');
};
