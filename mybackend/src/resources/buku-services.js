import db from "../utils/database.js";
import responseSucces from "../responses/response-succes.js";

export async function createBuku(req, res, next) {
  try {
    await db.query("INSERT INTO buku VALUES (?,?,?,?,?,?,?)", [
      req.body.no_isbn,
      req.body.nama_pengarang,
      req.body.tgl_cetak,
      req.body.kondisi == "true" ? 1 : 0,
      req.body.harga,
      req.body.jenis,
      req.body.harga_produksi,
    ]);
    const [data] = await db.query("SELECT * FROM buku WHERE no_isbn = ?", [
      req.body.no_isbn,
    ]);
    responseSucces(res, 200, data);
  } catch (error) {
    next(error);
  }
}

export async function getBuku(req, res, next) {
  try {
    const searchQuery = !req.query.search
      ? ""
      : ` WHERE nama_pengarang LIKE '%${req.query.search}%' OR no_isbn LIKE '%${req.query.search}%' \
    OR tgl_cetak LIKE '%${req.query.search}%' OR jenis LIKE '%${req.query.search}%'`;
    const [data] = await db.query(`SELECT * FROM buku ${searchQuery}`);
    responseSucces(res, 200, data);
  } catch (error) {
    next(error);
  }
}
export async function getByIdBuku(req, res, next) {
  try {
    const [data] = await db.query("SELECT * FROM buku WHERE no_isbn = ? ", [
      req.params.id,
    ]);
    responseSucces(res, 200, data[0]);
  } catch (error) {
    next(error);
  }
}

export async function updateBuku(req, res, next) {
  try {
    const dataUpdate = {
      nama_pengarang: req.body.nama_pengarang,
      tgl_cetak: req.body.tgl_cetak,
      kondisi: req.body.kondisi == "true" ? 1 : 0,
      harga: req.body.harga,
      jenis: req.body.jenis,
      harga_produksi: req.body.harga_produksi,
    };
    await db.query("UPDATE buku SET ? WHERE no_isbn = ? ", [
      dataUpdate,
      req.params.id,
    ]);
    const [data] = await db.query("SELECT * FROM buku WHERE no_isbn = ?", [
      req.params.id,
    ]);
    responseSucces(res, 200, data[0]);
  } catch (error) {
    next(error);
  }
}

export async function deleteBuku(req, res, next) {
  try {
    await db.query("DELETE FROM buku WHERE no_isbn = ? ", [req.params.id]);
    responseSucces(res, 200, undefined, "Berhasil Menghapus Buku");
  } catch (error) {
    next(error);
  }
}
