import processing.sound.*;
Global global; //always create the global variable before using any of the default classes (created by Don)

FFT fft;
AudioIn in;
int bands = 1024;
float[] spectrum = new float[bands];
float[] spec_timer = new float[1024];

PApplet pg; //PGraphics pg;
PFont f1;

int frame = 0;
boolean rendering = true;
Vine target_vine;

float depth = 0;
int theme = int(random(0,3));
Camera c;
ArrayList<Vine> v;
ArrayList<Vine> permanent;
ArrayList<Firework> fworks;
int timer = 0;
float max_spec;
Point p1;
float max_y=0;
float buffer = 1;
float bass_floor = 0;
float bass_ceiling = .1;
float bass_cutoff=3;
int firework_timer = 0;

int r,g,b;

boolean off = true;
int begin_timer=0;
void setup(){
  size(displayWidth,displayHeight,P3D);
  //f1 = loadFont("ArialMT-48.vlw");
  textAlign(LEFT,TOP);
  pg = this; //createGraphics(3000,2000,P3D);
  //pg.beginDraw();
  //pg.smooth();
  pg.background(0);
  //initialize global
  global = new Global();
  global.init();
  c = new Camera(1500,-200,0);
  
  v = new ArrayList<Vine>();
  permanent = new ArrayList<Vine>();
  fworks = new ArrayList<Firework>();
  p1 = new Point(100,0,0);
  Vine new_vine = new Vine(0,0,0,theme);
  v.add(new_vine);
  target_vine = v.get(0);
  begin_script();
  fft = new FFT(this,bands);
  in = new AudioIn(this,0);
  in.start();
  fft.input(in);
  change_target();
  for(float g:spec_timer){
    g=0; 
  }
  
  
}

void draw(){
  fft.analyze(spectrum);
  //p1.step();
  p1.render();
  render();
  
}

void render_fireworks(){
  firework_timer++;
  if(firework_timer>200){
    create_new_firework();
    fworks.remove(0);
    firework_timer = 0;
  }
  for(Firework f:fworks){
    f.render();
    
  }
}


void render_vines(){
  if(find_avg(0,1)*buffer>.002) lower_height();
  if(find_avg(0,1)*buffer<.0001) raise_height();
  if(begin_timer<200){begin_timer++;}
  if(begin_timer==200){begin_timer++;off=false;}
  
  for(Vine v0 : v){
      v0.step(spectrum[v0.getHerz()]*buffer*sqrt(sqrt(v0.getHerz()*2))/2,off);
      v0.render(); 
      //if(v0.get_y()<max_y){max_y = v0.get_y();}
  }
}

void render_permanent_vines(){
  for(Vine v0 : permanent){
      v0.step_permanent(spectrum[v0.getHerz()]);
      v0.render();
  }
}

boolean bass(){
   return bass(bass_cutoff);
}

boolean bass(float cutoff){
   if(bass_val()*200>cutoff){
     return true; 
   }
   return false;
}

float bass_val(){
  return find_avg(bass_floor,bass_ceiling);
}

void render(){
  frame++;
  if(rendering){
    //depth -= 1;
    pg.background(0);
    pg.pushMatrix();
    pg.translate(global.w/2,global.h/2,0);
    pg.noStroke();
    pg.fill(40,200,20);
    
    
    max_spec = max(spectrum);
    
    c.target(-650,-250,0);
    c.step(bass_val(),0);
    if(bass()){
      //pg.ellipse(200,200,200,200);
      //create_new_firework();
      //off=!off;
    }
    flames();
    //print_constrained_line(0,1);
    render_vines();
    render_fireworks();
    //render_permanent_vines();
    change_target();
    pg.popMatrix();
  }
}

float find_avg(float start, float end) {
  assert(end>start);
  float avg = 0;

  for (int i= int(1024*start); i<int(1024*end); ++i) {
    avg += spectrum[i];
  }
  //print (avg,"\n");
  assert(int(1023*end)-int(1023*start)>0);
  return (avg/(int(1023*end)-int(1023*start)));
}

void print_constrained_line(float from, float to) {
  for (int i = (int(bands*from)); i < (int(bands*to)); i++) {
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    line( -target_vine.last_x+i,0, -target_vine.last_x+i, -target_vine.last_y - spectrum[i]*-target_vine.last_y*8 );
  }
}

void begin_script(){
  for(int i=0;i<1;++i){
    Vine new_vine = new Vine(int(random(-1000,1000)),int(random(-1000,1000)),int(random(-1000,1000)),theme);
    v.add(new_vine);
  }
  for(int i=0;i<64;++i){
    Vine new_vine = new Vine(int(random(-1000,1000)),int(random(-1000,1000)),int(random(-1000,1000)),theme);
    permanent.add(new_vine);
  }
  for(int i=0;i<5;++i){
    create_new_firework();
  }
  
}

void flames(){
  for(int i=0;i<spectrum.length/16;++i){
    spec_timer[i*16]+=1;
    //println(spec_timer[0],">",spectrum[0]*40000);
    if(spec_timer[i*16]>1){
      create_new_vine(i*16); 
      spec_timer[i*16]=0;
    }
  }
}

void create_new_firework(){
  Firework f = new Firework(200,-300,400,displayWidth-300,-100);
  fworks.add(f);
  
  if(fworks.size()>5) fworks.remove(0);
}


void create_new_vine(int i){
  float horiz_pos = i*displayWidth/1024;
  int b_t = int(horiz_pos/displayWidth*255);
  //println(b_t);
  r=b=g=255;
  if(theme==0){ 
    r = 255-b_t;
    b = int(random(10,150));
    g = int(random(10,255));
  }
  else if (theme == 1){
    r = int(random(10,255));
    b = 200- b_t;
    g = int(random(10,255));
  }
  else{ 
    r = int(random(10,255));
    b = int(random(10,150));
    g = 255-b_t;
  }
  Vine new_vine = new Vine(horiz_pos-300,800,0,r,b,g);
  v.add(new_vine);
  new_vine.setHerz(i);
  
  //println(v.size());
  if(v.size()>1000/* || max_y<-500*/){v.remove(0);}
}

void delete_last_vine(){
  if(v.size()==1){
    target_vine = v.get(0);
    v.remove((v.size()-1)); 
  }
  else{
    v.remove((v.size()-1)); 
    if(v.contains(target_vine) == false){
      target_vine = v.get(int(random(0,v.size())));
    }
  }
}

void change_target(){
  if(v.size()>4){target_vine = v.get(v.size()-3);}
  else{ target_vine = v.get(v.size()-1);}
  /*
  int chosen = int(random(0,v.size()));
  if(chosen>=0){chosen = 0;}
  if(chosen>=v.size()){chosen = v.size()-1;}
  if(v.size()>0 && v.get(chosen)!=null){
    target_vine = v.get(chosen);
  }
  */
    
}

void raise_height(){buffer*=2;println("Raised height buffer to",buffer);}
void lower_height(){buffer/=2;println("Lowered height buffer to",buffer);}
void raise_bass_ceiling(){bass_ceiling+=.001;}
void lower_bass_ceiling(){bass_ceiling-=.001;}
void raise_bass_floor(){bass_floor+=.001;}
void lower_bass_floor(){bass_floor-=.001;}
void lower_bass_sensitivity(){bass_cutoff-=.1;}
void raise_bass_sensitivity(){bass_cutoff+=.1;}



void keyPressed(){
  if(rendering&&key=='r'){
    off=false;
  }
  if(rendering&&key=='f'){
    off=true; 
  }
  if(rendering&&key=='t'){
    if(buffer<300000)raise_height();
  }
  if(rendering&&key=='g'){
    if(buffer>.001)lower_height();
  }
  if(rendering&&key=='w'){
    if(bass_ceiling<1)raise_bass_ceiling();
  }
  if(rendering&&key=='s'){
    if(bass_ceiling>bass_floor+.01)lower_bass_ceiling();
  }
  if(rendering&&key=='q'){
    if(bass_floor<bass_ceiling-.01)raise_bass_floor();
  }
  if(rendering&&key=='a'){
    if(bass_floor<0)lower_bass_floor();
  }
  if(rendering&&key=='p'){
    println("\nBass Range:",bass_floor," - ",bass_ceiling);
    println("Bass Sensitivity:",bass_cutoff);
    println("Channel height:",buffer);
    println("Average magnitude:",find_avg(0,1)*buffer);
    String c = (off)?"OFF":"ON";
    println("System:",c);
  }
  if(rendering&&key=='d'){
    if(bass_cutoff>0)lower_bass_sensitivity();
  }
  if(rendering&&key=='e'){
    if(bass_cutoff<25)raise_bass_sensitivity();
  }
  if(rendering&&key=='z'){
    theme = 0;
  }
  if(rendering&&key=='x'){
    theme = 1;
  }
  if(rendering&&key=='c'){
    theme = 2;
  }
  
  
  
  
  
}