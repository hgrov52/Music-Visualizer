

class Vine extends Polyline{
  
  float last_x,last_y;
  float x,y,z,tx,ty,tz,vx,vy,vz;
  float speed = .0005;
  float damping = .02;
  float th = 11;
  float dthd1 = 200;
  float dthd2 = 50;
  float dthm = 10;
  float target_distance = 100;
  float redirect_distance = 60;
  int r,g,b;
  int buffer;
  float start;
  int herz=0;
  Vector v;
  Vine(float $x,float $y,float $z, int theme){
    super();
    tx = x = $x; ty = y = $y; tz = z = $z;
    vx = vy = vz = 0;
    v = new Vector(0,0,0);
    add_point(new Point($x,$y,$z));
    start = $x;
    
    r = int(random(10,255));
    g = int(random(10,255));
    b = int(random(10,255));
    if(theme == 0){
      r=0; 
    }
    if(theme == 1){
      g=0;
    }
    if(theme == 2){
      b=0;
    }
    buffer = int(random(-15,15));
    
  }
  
  void setHerz(int h){
    herz = h; 
  }
  
  
  float get_y(){return y;}
  
  int getHerz(){
    return herz; 
  }
  
  Vine(float $x,float $y,float $z, int $r, int $g, int $b){
    super();
    tx = x = $x; ty = y = $y; tz = z = $z;
    vx = vy = vz = 0;
    v = new Vector(0,0,0);
    add_point(new Point($x,$y,$z));
    start = $x;
    
    r = $r;
    g = $g;
    b = $b;
    
    buffer = int(random(-15,15));
  }
  
  
    void step(float max_spec, boolean off){
    float d = dist(x,y,z,tx,ty,tz);
    if(d<target_distance){
      tx += random(-redirect_distance,redirect_distance);
      ty += random(-redirect_distance,redirect_distance);
      //tx = global.constrainX(tx);
      //ty = global.constrainY(ty);
      //tz = 0;
    }
    vx += (tx-x)*speed;
    vy += (ty-y)*speed;
    //vz += (tz-z)*speed;
    vx *= 1-damping;
    vy *= 1-damping;
    //vz *= 1-damping;
    x = vx*max_spec*10000+start;
    y += (off)?-.1:-max_spec*10000;
    //z += vz;
    last_x = x;
    last_y = y;
    add_point(new Point(x,y,depth*100));
  }
  
  void step_permanent(float max_spec){
    float d = dist(x,y,z,tx,ty,tz);
    if(d<target_distance){
      tx += random(-redirect_distance,redirect_distance);
      ty += random(-redirect_distance,redirect_distance);
      //tx = global.constrainX(tx);
      //ty = global.constrainY(ty);
      //tz = 0;
    }
    vx += (tx-x)*speed;
    vy += (ty-y)*speed;
    //vz += (tz-z)*speed;
    vx *= 1-damping;
    vy *= 1-damping;
    //vz *= 1-damping;
    //x = vx*max_spec*500+start;
    y = max_spec*10000;
    //z += vz;
    last_x = x;
    last_y = y;
    add_point(new Point(x,y,depth*100));
  }
  
  void step_firework(int index,int total){
    tx += cos(2*PI*index/total);
    ty += sin(2*PI*index/total);
    
    vx += (tx-x)*speed;
    vy += (ty-y)*speed;
    //vz += (tz-z)*speed;
    vx *= 1-damping;
    vy *= 1-damping;
    //vz *= 1-damping;
    x += vx;
    y += vy;
  }
  
  void step(){
    float d = dist(x,y,z,tx,ty,tz);
    if(d<target_distance){
      tx += random(-redirect_distance,redirect_distance);
      ty += random(-redirect_distance,redirect_distance);
      //tx = global.constrainX(tx);
      //ty = global.constrainY(ty);
      //tz = 0;
    }
    vx += (tx-x)*speed;
    vy += (ty-y)*speed;
    //vz += (tz-z)*speed;
    vx *= 1-damping;
    vy *= 1-damping;
    //vz *= 1-damping;
    x += vx;
    y += vy;
    //z += vz;
    last_x = x;
    last_y = y;
    add_point(new Point(x,y,depth*100));
  }
  
  int[] get_target(){
    int[] last_point = {int(last_x),int(last_y)};
    return last_point;
  }
  
  void render(){
    pg.beginShape(QUAD_STRIP);
    int l = max(nsegments-segments.length,0);
    for(int i=l;i<nsegments;i++){
      float dx = 0;
      float dy = 0;
      if(i>l){
        float dth = 0;
        if(i-l<dthd1){
          dth = dthm-min(dthm*(i-l)/dthd1,dthm);
        }else if(i-l>min(nsegments,segments.length)-dthd2){
          dth = dthm-min(dthm*(min(segments.length,nsegments)-(i-l))/dthd2,dthm);
        }
        if(abs(segments[(i-1)%segments.length].p2.y-segments[i%segments.length].p2.y)>global.distance_tolerance){
          v.vx = segments[(i-1)%segments.length].p2.y-segments[i%segments.length].p2.y;
          v.vy = -(segments[(i-1)%segments.length].p2.x-segments[i%segments.length].p2.x);
          v.vz = 0;
          v.unitize();
          v.scale(max(th/2-dth/2,0));
          dx = v.vx;
          dy = v.vy;
        }else{
          dx = 0;
          dy = max(th/2-dth/2,0);
        }
      }
      //fill(150*(i-l)/segments.length);
      pg.fill(r,g,b);
      pg.vertex(segments[i%segments.length].p2.x-dx,segments[i%segments.length].p2.y-dy,segments[i%segments.length].p2.z);
      pg.vertex(segments[i%segments.length].p2.x+dx,segments[i%segments.length].p2.y+dy,segments[i%segments.length].p2.z);
    }
    pg.endShape();
    //stroke(255,0,0);
    //super.render();
    //println(tx,ty);
    //pg.ellipse(tx,ty,int(abs(30000/tx)),int(abs(30000/ty)));
  }
}