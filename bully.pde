import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import ddf.minim.*;

ArrayList<Fruit> fruits;
int num_of_fruits = 25;
PBox2D box2d;
PGraphics offscreen;
Collector collector;
FixtureDef fd;
int should_panic = 0;
float panic_start = 0.0;
Minim minim;
AudioPlayer scream, grab, drop, sigh;



void setup() {
  // box2D setup
  size(600, 600, P3D);
  box2d = new PBox2D(this);
  box2d.createWorld();
  offscreen = createGraphics(600, 600, P3D);

  minim = new Minim (this);
  scream = minim.loadFile ("sad.mp3");
  grab = minim.loadFile ("blub.mp3");
  drop = minim.loadFile ("drop.mp3");
  sigh = minim.loadFile ("sigh.mp3");

  // creates collector
  collector = new Collector(width/2, height/2, 40);

  // create fruits
  fruits = new ArrayList<Fruit>();
  int gridx = 0;
  int gridy = 0;
  int fruits_per_row = (int)sqrt(num_of_fruits);
  for(int i = 0; i < num_of_fruits; i++)
  {
    int x = (int)random(50, width - 50);
    int y = (int)random(50, height - 50);

    fruits.add(new Fruit(x,y, true));
    fruits.get(i).setGrid(width/4 + gridx * 35, 
                          height/4 + gridy * 35);

    gridx++;
    if(gridx >= fruits_per_row)
    {
      gridx = 0;
      gridy++;
    }
  }

  // no going out of bounds
  Boundary b = new Boundary(0,height,width,10);// bottom
  b = new Boundary(0,-10,width,10);             // top
  b = new Boundary(-10,0,10,height);            // left
  b = new Boundary(width,0,10,height);         // right

  box2d.setGravity(0, 0);
}

void draw() {
  if(mousePressed)  // user pushes the balls
    mousePush();
  
  box2d.step();
  background(182, 213, 222);
  background(108, 147, 153);
  if(should_panic == 2)
  {
    //stop panicking after 3 secs
    if(millis() - panic_start > 3000.0)
    {
      should_panic = 0;
      collector.setLinearVelocity(new Vec2(0,0));
      collector.seekTarget = false;
      collector.gotTarget = false;
      scream.cue(0);
    }

    // every 300 milliseconds, panic
    if(millis() % 100.0 < 25.0)
    {
      float x = 500000000;
      float y = 500000000;

      if(random(-1,1) < 0.0)
        x *= -1;
      if(random(-1,1) < 0.0)
        y *= -1;
      collector.applyForce(new Vec2(x,y));
      collector.setAngularVelocity(1000.0);
    }
  }
  else if(should_panic == 1)
  {
    //stop panicking after 3 secs
    if(millis() - panic_start > 1000.0)
    {
      should_panic = 0;
      collector.setLinearVelocity(new Vec2(0,0));
      collector.seekTarget = false;
      collector.gotTarget = false;
    }
  }
  else
    collectorSeek();



  for (Fruit f: fruits) {
    f.display();
  }
  collector.display();

}