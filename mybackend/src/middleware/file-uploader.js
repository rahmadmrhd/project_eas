import multer from "multer";

const storage = multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, "public/");
  },
  filename: function (req, file, callback) {
    callback(null, `${file.originalname.split(".")[0]}-${Date.now()}.jpg`);
  },
});
const uploader = multer({ storage: storage });
export default uploader;
