class Firework{
  int nvines;
  int originx;
  int originy;
    
  ArrayList<Vine> fvines;
  
  Firework(){
    nvines = 5;
    fvines = new ArrayList<Vine>();
    originx=0;
    originy=0;
  }
  
  Firework(int $nvines,int lower_bound_x,int lower_bound_y,int upper_bound_x,int upper_bound_y){
    nvines = $nvines;
    fvines = new ArrayList<Vine>();
    originx = int(random(lower_bound_x,upper_bound_x));
    originy = int(random(lower_bound_y,upper_bound_y));
    populate_fvines();
  }
  
  void populate_fvines(){
    for(int i=0;i<nvines;++i){
      Vine new_vine = new Vine(originx,originy,0,255,255-30,30); //x,y,z,r,g,b
      fvines.add(new_vine);
    }
  }
  
 
  
  void render(){
    for(int i=0;i<nvines;++i){
      fvines.get(i).step();
      fvines.get(i).render();
    }
  }
}  
  
  