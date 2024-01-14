const responseSucces = (res, status, data, message) => {
  res.status(status).json({ status: status, message: message, data: data });
};

export default responseSucces;
