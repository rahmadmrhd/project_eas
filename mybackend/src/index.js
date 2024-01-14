import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import notFoundMiddleware from "./middleware/not-found.js";
import errorMiddleware from "./middleware/error-middleware.js";
import routes from "./routes/routes.js";
import multer from "multer";

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Credentials", "true");
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

app.use("/images", express.static("public", { index: false }));

app.use(routes);
app.use(notFoundMiddleware);
app.use(errorMiddleware);

const port = 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port} => http://localhost:${port}`);
});
