class Camera{
  float x,y,z,tx,ty,tz,vx,vy,vz;
  float speed = .00018;
  float damping = .01;
  float rotating_var;
  Camera(float $x,float $y,float $z){
    tx = x = $x; ty = y = $y; tz = z = $z;
    vx = vy = vz = 0;
    rotating_var = .5;
  }
  void target(float $tx,float $ty,float $tz){
    tx = $tx+width/3; ty = $ty+height/4; tz = $tz;
  }
  void step(float max_spec,float depth){
    
    vx += (tx-x)*speed;
    vy += (ty-y)*speed;
    vz += (tz-z)*speed;
    vx *= 1-damping;
    vy *= 1-damping;
    vz *= 1-damping;
    x += vx;
    y += vy/*+= max_spec*/;
    z = max_spec*100;
    pg.translate(x,y,z);
  }
  
  float get_z(){
    return z; 
  }
  
  
  void twist(float sound){
    rotate(sound); 
  }
  
  void twist(){
    rotate(rotating_var);
  }
  
  float[] get_target(){
    float[] to_return = {tx,ty,tz};
    return to_return; 
    
  }
}