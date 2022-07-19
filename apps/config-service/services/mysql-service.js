const mysql = require('mysql');
const util = require('util');

const tableName = 'tmp';
const insertKeys = 'userId, serviceId, created, isMarkedForDeletion';

const dbCredentials = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB,
  user: process.env.DB_USER,
  password: process.env.DB_PW,
};

const insertTmpServiceQuery = async (connection, userId, serviceId, dateTime, deleteRecord = false) => {
  const query = util.promisify(connection.query).bind(connection);
  const statement = `INSERT INTO ${tableName} (${insertKeys})
                     VALUES ('${userId}', '${serviceId}', '${dateTime}', ${deleteRecord})`;

  console.log(`Executing query: ${statement}`);
  return query(statement);
};

exports.insertTmpService = async (userId, serviceId, dateTime, deleteRecord = false) => {
  let connection, result;
  try {
    connection = mysql.createConnection(dbCredentials);
    await connection.beginTransaction();
    result = await insertTmpServiceQuery(connection, userId, serviceId, dateTime, deleteRecord);
    await connection.commit();
    return result;
  } catch (e) {
    result = e.message;
    console.error(e);
    if (connection) {
      await connection.rollback();
    }
    return result;
  } finally {
    if (connection) {
      const conEnd = util.promisify(connection.end).bind(connection);
      await conEnd();
    }
  }
};

exports.invokeLambda = async (lambdaArn, payload) => {
  let connection, result;
  try {
    connection = mysql.createConnection(dbCredentials);
    await connection.beginTransaction();
    const query = util.promisify(connection.query).bind(connection);
    const statement = `SELECT lambda_async('${lambdaArn}', '${JSON.stringify(payload)}');`;
    result = query(statement);
    await connection.commit();
    return result;
  } catch (e) {
    result = e.message;
    console.error(e);
    if (connection) {
      await connection.rollback();
    }
    return result;
  } finally {
    if (connection) {
      const conEnd = util.promisify(connection.end).bind(connection);
      await conEnd();
    }
  }
};
