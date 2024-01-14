import ResponseError from "../responses/response-error";
import db from "../app/database";

export async function authCustomerMiddleware(req, res, next) {
  const token = req.get("Authorization")?.split(" ");
  const [user] = await db.query("SELECT * FROM `users` WHERE token = ?", [
    token?.[1],
  ]);
  if (!user || user.length <= 0) {
    return next(new ResponseError(401, "Unauthorized"));
  }
  res.locals.customer = user[0];
  next();
}
