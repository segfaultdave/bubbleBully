class Collector{
	
  // We need to keep track of a Body, and a width and height  
  Body body;
  float diameter;
  boolean seekTarget = false;
  boolean gotTarget = false;
  int targetIndex = 0;

  Collector(float x, float y, float d){
    diameter  = d;
	  makeBody (new Vec2(x, y), diameter, diameter);
  }
  
  void killBody() {
    box2d.destroyBody(body);
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

  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    //float a = tan(pos.y/pos.x) + 3*PI/4;

    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    if(should_panic == 2)
        fill(255, 0, 0);
    else if(should_panic == 1)
        fill(251, 104, 155);
    else
        fill(103, 177, 252);

    noStroke();
    
    ellipse(0, 0, diameter, diameter);

    for(int i = 0; i < 10; i++)
    {
        ellipse(0, 0, 5, 1.5*diameter);
        rotate(2.0*PI/((float)10));
    }
    popMatrix();
    pushMatrix();
    translate(pos.x, pos.y);
    fill(0, 200);
    ellipse(-diameter/6, 0, 4, 6);
    ellipse(diameter/6, 0, 4, 6);
    popMatrix();
  }

  void makeBody (Vec2 center, float w_, float h_) {
 
    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/5);
    float box2dH = box2d.scalarPixelsToWorld(h_/5);
    sd.setAsBox(box2dW, box2dH);
 
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics, fun to mess with
    fd.density = 10;
    fd.friction = 0.1;
    fd.restitution = 0.01;
    //fd.isSensor = true;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld (center));
 
    body = box2d.createBody(bd);
    body.createFixture(fd);
 
	 // Give it no velocity
    body.setLinearVelocity(new Vec2(0, 0));
    body.setAngularVelocity(0);
  }
}
