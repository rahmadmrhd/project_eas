import db from "../utils/database.js";
import responseSucces from "../responses/response-succes.js";

export async function createPengguna(req, res, next) {
  try {
    await db.query("INSERT INTO pengguna VALUES (?,?,?,?,?,?)", [
      req.body.id_pengguna,
      req.body.nama,
      req.body.alamat,
      req.body.tgl_daftar,
      req.body.no_telp,
      req.file.filename,
    ]);
    const [data] = await db.query(
      "SELECT * FROM pengguna WHERE id_pengguna = ?",
      [req.body.id_pengguna]
    );
    responseSucces(res, 200, data);
  } catch (error) {
    next(error);
  }
}

export async function getPengguna(req, res, next) {
  try {
    const searchQuery = !req.query.search
      ? ""
      : ` WHERE nama LIKE '%${req.query.search}%' OR alamat LIKE '%${req.query.search}%' \
    OR tgl_daftar LIKE '%${req.query.search}%' OR no_telp LIKE '%${req.query.search}%'`;
    const [data] = await db.query(`SELECT * FROM pengguna ${searchQuery}`);
    responseSucces(res, 200, data);
  } catch (error) {
    next(error);
  }
}
export async function getByIdPengguna(req, res, next) {
  try {
    const [data] = await db.query(
      "SELECT * FROM pengguna WHERE id_pengguna = ? ",
      [req.params.id]
    );
    responseSucces(res, 200, data[0]);
  } catch (error) {
    next(error);
  }
}

export async function updatePengguna(req, res, next) {
  try {
    const dataUpdate = {
      id_pengguna: req.body.id_pengguna,
      nama: req.body.nama,
      alamat: req.body.alamat,
      tgl_daftar: req.body.tgl_daftar,
      no_telp: req.body.no_telp,
      foto: req.file.filename,
    };
    await db.query("UPDATE pengguna SET ? WHERE id_pengguna = ? ", [
      dataUpdate,
      req.params.id,
    ]);
    const [data] = await db.query(
      "SELECT * FROM pengguna WHERE id_pengguna = ?",
      [req.params.id]
    );
    responseSucces(res, 200, data[0]);
  } catch (error) {
    next(error);
  }
}

export async function deletePengguna(req, res, next) {
  try {
    await db.query("DELETE FROM pengguna WHERE id_pengguna = ? ", [
      req.params.id,
    ]);
    responseSucces(res, 200, undefined, "Berhasil Menghapus Pengguna");
  } catch (error) {
    next(error);
  }
}
