import ResponseError from "../responses/response-error.js";

const notFoundMiddleware = (req, res, next) => {
  return next(new ResponseError(404, `Not Found - ${req.originalUrl}`));
};

export default notFoundMiddleware;
