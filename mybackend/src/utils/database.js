import mysql from "mysql2";

//isi sesuai konfigurasi databasemu
const db = mysql
  .createPool({
    host: "localhost",
    port: 3307,
    user: "admin",
    password: "admin",
    database: "perpustakaan",
  })
  .promise();

export default db;
