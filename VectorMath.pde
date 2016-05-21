
/**
 * Find the parallel and perpendicular components of b wrt a.
 */
PVector[] project(PVector aIn, PVector bIn) {
  PVector a = aIn.copy().normalize();
  PVector b = bIn.copy();
  PVector proj = a.copy().mult(a.dot(b)/a.mag());
  PVector tang = b.copy().sub(proj);
  return new PVector[] {proj, tang};
}

/**
 * Get the angle between but maintain a sign (unlike processing).
 * clockwise a to b is -ve.
 */
float _angleBetween(PVector aIn, PVector bIn) {
  PVector a = aIn.copy().rotate(-aIn.heading());
  PVector b = bIn.copy().rotate(-aIn.heading());
  float angle = PVector.angleBetween(a,b);
  if(b.y < 0) {
    angle *= -1.0;
  }
  return angle;
}