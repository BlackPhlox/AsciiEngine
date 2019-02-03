class PlayerGUI{
  Chart heartRateChart;
  ControlP5 cp5;
  
  PlayerGUI(PApplet p){
    cp5 = new ControlP5(p);
    setupGUI();
  }
  
  boolean pre;
  void updateHeartbeatSensor(){
    boolean f = frameCount % round(fps/(world.player.bpm/60)) == 0;
    heartRateChart.push("incoming", 
      (f?15:0)+(pre?-0.75:0)*20
    );
    if(f) pre = true; else pre = false;
  }
  
  void setupGUI() {
    Group dialogWindow = cp5.addGroup("dialogWindow")
                           .setSize(width/2,height)
                           .setBackgroundColor(color(200,50))
                           .close();
                           
    cp5.addButton("d1")
      .setLabel("Dialog")
      .setPosition(0, 0)
      .setSize(width/2, 20)
      .lock()
      .setGroup(dialogWindow);
      ;
  
    cp5.addButton("d2")
      .setLabel("NPC_NAME")
      .setPosition(20, 40)
      .setSize(width/2-40, 20)
      .lock()
      .setGroup(dialogWindow);
      ;
  
    cp5.addToggle("d3")
      .setLabel("Follow me")
      .setPosition(20, 80)
      .setSize(45, 20)
      .setMode(Toggle.CHECKBOX)
      .setGroup(dialogWindow);
      ;
  
    cp5.addToggle("d4")
      .setLabel("Trade")
      .setPosition(80, 80)
      .setSize(45, 20)
      .setMode(Toggle.CHECKBOX)
      .setGroup(dialogWindow);
      ; 
      
    cp5.addToggle("d5")
      .setLabel("Debug")
      .setPosition(140, 80)
      .setSize(45, 20)
      .setMode(Toggle.CHECKBOX)
      .setGroup(dialogWindow);
      ;
    
    cp5.addToggle("d6")
      .setLabel("Patrol")
      .setPosition(200, 80)
      .setSize(45, 20)
      .setMode(Toggle.CHECKBOX)
      .setGroup(dialogWindow);
      ; 
  
    Group inventoryWindow = cp5.addGroup("inventoryWindow")
                             .setPosition(width-width/2, 0)
                             .setSize(width/2,height)
                             .setBackgroundColor(color(200,50))
                             .close();
                           
  
    cp5.addButton("i1")
      .setLabel("Inventory")
      .setPosition(0, 0)
      .setSize(width/2, 20)
      .lock()
      .setGroup(inventoryWindow);
      ;
    
    Group statsWindow = cp5.addGroup("statsWindow")
                             .setSize(width/2,height)
                             .setBackgroundColor(color(200,50))
                             .close();
  
    heartRateChart = cp5.addChart("heartRate")
      .setPosition(0, 20)
      .setSize(width/2-80, 100)
      .setRange(-20, 20)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      .setColorCaptionLabel(color(40))
      .setGroup(statsWindow);
      ;
      
    heartRateChart.addDataSet("incoming");
    heartRateChart.setData("incoming", new float[100]);
    
    cp5.addButton("b1")
       .setLabel("Bpm")
       .setPosition(width/2-80,20)
       .setSize(80,100)
       .setGroup(statsWindow);
       
    cp5.addButton("s1")
       .setLabel("Stats")
       .setPosition(0, 0)
       .setSize(width/2, 20)
       .lock()
       .setGroup(statsWindow)
       ;
    
    Group statGroup = cp5.addGroup("statGroup")
                        .setGroup(statsWindow)
                        .setPosition(0,120)
                        .setSize(width/2,0);
    
    cp5.addSlider("v1", 0, 255)
      .setPosition(10,10)
      ;
  
    addStat("v1","Health",statGroup);
  }
  
  void addStat(String cName, String labelName, Group g){
    Controller c1 = cp5.getController(cName);
    c1.setCaptionLabel(labelName);
    setStatStyle(c1);
    c1.setColorBackground(color(50,0,0));
    c1.setColorForeground(color(255,0,0));
    c1.setGroup(g);
    c1.setValue(100);
    c1.lock();
    
  }
  
  void setStatStyle(Controller c) {
    // add some padding to the caption label background
    c.setHeight(15);
    
    c.setWidth(width/2-80);
    
    c.getCaptionLabel().getStyle().setPadding(4, 4, 3, 4);
  
    // shift the caption label up by 4px
    c.getCaptionLabel().getStyle().setMargin(-4, 0, 0, 0); 
  
    // set the background color of the caption label
    c.getCaptionLabel().setColorBackground(color(10, 20, 30, 140));
  }
}
