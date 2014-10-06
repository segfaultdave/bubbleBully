class Fruit {
 
  // We need to keep track of a Body, and a width and height
  Body body;
  float diameter;
  boolean touchable;
  int gridx, gridy;
 
  Fruit (float 	x, float y, boolean t) {
    diameter = random (15, 35);
    touchable = t;
    gridx = gridy = 0;

    // Add the Fruit to the box2d world
    makeBody (new Vec2(x, y), diameter, diameter);
  }

  Fruit (float  x, float y, float d, boolean t) {
    diameter = d;
    touchable = t;

    // Add the Fruit to the box2d world
    makeBody (new Vec2(x, y), diameter, diameter);
  }
 
  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  void setGrid(int gx, int gy)
  {
    gridx = gx;
    gridy = gy;
  }
 
  void applyForce (Vec2 v) {
    body.applyForce(v, body.getWorldCenter());
  }

  void setLinearVelocity (Vec2 v) {
    body.setLinearVelocity(v);
  }
 
  void setAngularVelocity (float v) {
    body.setAngularVelocity(v);
  }
 
  boolean done() {
    // Is the particle ready for deletion?
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+diameter*diameter) {
      killBody();
      return true;
    }
    return false;
  }
 
  // Drawing the box. 
  // Notice how we do all the drawing in Keystone's offscreen buffer!
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
 
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(220, 220, 220, 100);
    stroke(255);
    ellipse(0, 0, diameter, diameter);
    popMatrix();
  }
 
  // This function adds the rectangle to the box2d world
  void makeBody (Vec2 center, float w_, float h_) {
 
    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);
 
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics, fun to mess with
    fd.density = 10;
    fd.friction = 0.3;
    fd.restitution = 0.15;

    if(!touchable)
      fd.isSensor = true;
 
    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld (center));
 
    body = box2d.createBody(bd);
    body.createFixture(fd);
 
    // Give it no velocity
    body.setLinearVelocity(new Vec2(-2, 2));
    body.setAngularVelocity(30);
  }
}