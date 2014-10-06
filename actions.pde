void mousePush()
{
  if((mouseX - pmouseX)*(mouseX - pmouseX) + 
     (mouseY - pmouseY)*(mouseY - pmouseY) > 4000)  // full repel
  {
    for(int i = 0; i < fruits.size(); i++) 
    {
      Fruit f = fruits.get(i);
      Vec2 fpos = box2d.getBodyPixelCoord(f.body);
      float dx = fpos.x - mouseX;
      float dy = fpos.y - mouseY;
      float dh = sqrt(dx*dx + dy*dy);

      if(!(f.touchable) && dh < 200.0)
      {
        float x = fpos.x;
        float y = fpos.y;
        float d = f.diameter;
        int gx = f.gridx;
        int gy = f.gridy;

        f.killBody();
        fruits.remove(i);
        f = new Fruit(x, y, d, true);
        f.setGrid(gx, gy);
        fruits.add(f);

        continue;
      }

      if (dh > 1.0  && dh < 200.0) {
        float componentInX = dx/dh;
        float componentInY = dy/dh;
        float proportionToDistanceSquared = 1.0/(dh*dh);
         
        float repulsionForcex = 500000000.0 * componentInX * proportionToDistanceSquared;
        float repulsionForcey = 500000000.0 * componentInY * proportionToDistanceSquared;
        f.applyForce(new Vec2(repulsionForcex, repulsionForcey));

        int oldvalue = should_panic;
        should_panic = 2;
        panic_start = millis();

        if(should_panic != oldvalue)
          scream.play();
      }
    }
  }
  else      // move only 1 orb
  {
    for(int i = 0; i < fruits.size(); i++)
    {
      Fruit f = fruits.get(i);
      Vec2 fpos = box2d.getBodyPixelCoord(f.body);

      // mouse actually clicked on it
      if(fpos.x - f.diameter/2.0 < mouseX && 
         fpos.x + f.diameter/2.0 > mouseX &&
         fpos.y - f.diameter/2.0 < mouseY && 
         fpos.y + f.diameter/2.0 > mouseY)
      {
        float dx = fpos.x - mouseX;
        float dy = fpos.y - mouseY;

        float dh = sqrt(dx*dx + dy*dy);
        if (dh > 1.0)
        {
          float componentInX = dx/dh;
          float componentInY = dy/dh;

          float fx = 45.0 * componentInX;
          float fy = 45.0 * componentInY;

          if(!(f.touchable))  // make touchable, and panic
          {
            float x = fpos.x;
            float y = fpos.y;
            float d = f.diameter;
            int gx = f.gridx;
            int gy = f.gridy;

            f.killBody();
            fruits.remove(i);
            f = new Fruit(x, y, d, true);
            f.setGrid(gx,gy);
            fruits.add(f);

            float panicx = 25;
            float panicy = 25;

            if(random(-1,1) < 0.0)
              panicx *= -1;
            if(random(-1,1) < 0.0)
              panicy *= -1;
            collector.setLinearVelocity(new Vec2(panicx,panicy));

            // decides whether to play sound
            if(should_panic != 2)
            {
              int oldvalue = should_panic;
              should_panic = 1;
              panic_start = millis();

              if(should_panic != oldvalue)
              {
                sigh.play();
                sigh.cue(0);
              }
            }

          }

          f.setLinearVelocity(new Vec2(fx, -fy));

        }

        break;

      }
    }
  }
}

void collectorSeek()
{
  Vec2 cpos = box2d.getBodyPixelCoord(collector.body);

  if(!(collector.seekTarget) && 
     !(collector.gotTarget))    // go seek target
  {
    int i = -1;
    int finishedcount = 0;
    float mindh = width*width + height*height;  

    for (Fruit f: fruits)
    {
      i++;
      if(!(f.touchable))  // already collected
      {
        finishedcount++;
        continue;
      }

      Vec2 fpos = box2d.getBodyPixelCoord(f.body);
      float dx = fpos.x - cpos.x;
      float dy = fpos.y - cpos.y;
      float dh = sqrt(dx*dx + dy*dy);

      if(dh < mindh)  // find closest
      {
        mindh = dh;
        collector.targetIndex = i;
      }
    }
    if(finishedcount == fruits.size())
    {
      collector.setLinearVelocity(new Vec2(0,0));
      collector.setAngularVelocity(5);
    }
    else
      collector.seekTarget = true;
  }

  else if(collector.gotTarget)  // we got the target!
  {
    Fruit f = fruits.get(collector.targetIndex);
    Vec2 fpos = box2d.getBodyPixelCoord(f.body);

    // for collector
    float dx = f.gridx - cpos.x;
    float dy = f.gridy - cpos.y;
    float dh = sqrt(dx*dx + dy*dy);

    if (dh > 1.0)
    {
      float componentInX = dx/dh;
      float componentInY = dy/dh;

      float fx = 450.0 * componentInX;
      float fy = 450.0 * componentInY;
      Vec2 v = collector.body.getLinearVelocity();
      float vmag = sqrt(v.x*v.x + v.y*v.y);

      
      if(vmag > 500.0)
        collector.setLinearVelocity(new Vec2(vmag*dx/dh, -vmag*dy/dh));
      else
        collector.applyForce(new Vec2(fx, -fy));
      
      collector.setAngularVelocity(5000.0/dh);
    }

    // for target
    dx = cpos.x - fpos.x;
    dy = cpos.y - fpos.y;
    dh = sqrt(dx*dx + dy*dy);
    if (dh > 1.0)
    {
      float componentInX = dx/dh;
      float componentInY = dy/dh;

      float fx = 45.0 * componentInX;
      float fy = 45.0 * componentInY;
      f.setLinearVelocity(new Vec2(fx, -fy));
    }

    // reached pile
    if(abs(f.gridx - cpos.x) <= 35 &&
       abs(f.gridy - cpos.y) <= 35)
    {
      drop.play();
      drop.cue(0);
      collector.gotTarget = false;
      collector.seekTarget = false;

      float d = f.diameter;
      int gx = f.gridx;
      int gy = f.gridy;

      f.killBody();
      fruits.remove(collector.targetIndex);
      f = new Fruit(gx, gy, d, false);
      f.setGrid(gx,gy);
      fruits.add(f);

      f.setLinearVelocity(new Vec2(0,0));
      f.setAngularVelocity(0);
    }

  }
  else                          // going towards target
  {
    Fruit f = fruits.get(collector.targetIndex);
    Vec2 fpos = box2d.getBodyPixelCoord(f.body);

    float dx = fpos.x - cpos.x;
    float dy = fpos.y - cpos.y;
    float dh = sqrt(dx*dx + dy*dy);
    if (dh > 1.0)
    {
      float componentInX = dx/dh;
      float componentInY = dy/dh;

      float fx = 450.0 * componentInX;
      float fy = 450.0 * componentInY;
      Vec2 v = collector.body.getLinearVelocity();
      float vmag = sqrt(v.x*v.x + v.y*v.y);

      if(vmag > 500.0)
        collector.setLinearVelocity(new Vec2(vmag*dx/dh, -vmag*dy/dh));
      else
        collector.applyForce(new Vec2(fx, -fy));
      
      collector.setAngularVelocity(5000.0/dh);
    }

    // nearing the target
    if(sqrt((cpos.y - fpos.y)*(cpos.y - fpos.y) +
            (cpos.x - fpos.x)*(cpos.x - fpos.x)) <= 
            (collector.diameter/1.2 + f.diameter/1.2))
    {
      float x = fpos.x;
      float y = fpos.y;
      float d = f.diameter;
      int gx = f.gridx;
      int gy = f.gridy;

      f.killBody();
      fruits.remove(collector.targetIndex);
      f = new Fruit(x, y, d, false);
      f.setGrid(gx,gy);

      fruits.add(f);
      collector.targetIndex = fruits.size() - 1;

      collector.gotTarget = true;
      collector.seekTarget = false;

      collector.setLinearVelocity(new Vec2(0, 0));
      collector.setAngularVelocity(0);
      grab.play();
      grab.cue(0);
    }

  }
}

