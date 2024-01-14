import ResponseError from "../responses/response-error.js";

const errorMiddleware = (err, req, res, next) => {
  if (!err) {
    return next();
  }
  if (err instanceof ResponseError) {
    res
      .status(err.status)
      .json({ status: err.status, message: err.message })
      .end();
  } else {
    res.status(500).json({ status: 500, message: err.message }).end();
  }
};

export default errorMiddleware;
