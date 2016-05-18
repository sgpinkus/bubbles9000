
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