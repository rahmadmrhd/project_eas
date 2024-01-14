import express from "express";
import {
  createBuku,
  deleteBuku,
  getBuku,
  getByIdBuku,
  updateBuku,
} from "../resources/buku-services.js";
import uploader from "../middleware/file-uploader.js";
import {
  createPengguna,
  deletePengguna,
  getByIdPengguna,
  getPengguna,
  updatePengguna,
} from "../resources/pengguna-services.js";

const routes = express.Router();
routes.post("/buku", uploader.none(), createBuku);
routes.get("/buku", getBuku);
routes.get("/buku/:id", getByIdBuku);
routes.put("/buku/:id", uploader.none(), updateBuku);
routes.delete("/buku/:id", deleteBuku);

routes.post("/pengguna", uploader.single("foto"), createPengguna);
routes.get("/pengguna", getPengguna);
routes.get("/pengguna/:id", getByIdPengguna);
routes.put("/pengguna/:id", uploader.single("foto"), updatePengguna);
routes.delete("/pengguna/:id", deletePengguna);

export default routes;
