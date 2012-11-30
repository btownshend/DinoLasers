import hypermedia.net.*;    // import UDP library
import java.util.ArrayList.*;

UDP udp;  // define the UDP object (sets up)

ArrayList <MotionEvent> motionList;

public static final int MOTION_EVENT_BUFFER_SIZE = 50;

float maxAccel, maxRotation = 0;

void setup() {
 size(480,800);
 
 background(0);
 smooth();
 
  // create a new datagram connection on port 6000
  // and wait for incoming message
  udp = new UDP( this, 10552 ); 
  udp.log( true );        // <-- printout the connection activity
  udp.listen( true );
  
  motionList = new ArrayList<MotionEvent>();
}

int boxSize = 100;
int x = -boxSize;


void draw() {
    background(0);
    
    if (x > width) {
        x = -boxSize;
    }
    fill(128);
    rect(x, height - boxSize, boxSize, boxSize);
    x++;
    
    
    int plotStartX = width - 50; 
    
    int singlePlotWidth = width - 100;
    int singlePlotHeight = 100;        
    int singleEventWidth = singlePlotWidth / MOTION_EVENT_BUFFER_SIZE;
    
    int currPlotX = plotStartX;
    int plotStartY = 120;
    int plotPaddingY = 10;
    
    stroke(0,0,255);

    // draw line plots
    for (int i = 0; i < 6; i++) {
        
        if (motionList.size() > 1) { // make sure we have at least two values
            
            int midPoint = plotStartY + (singlePlotHeight / 2);
            
            // create scale factor so we hopefully use the majority of the plotheight
            float scaleFactor = 0;
            if (i < 3) { // use max accel
                scaleFactor = singlePlotHeight / maxAccel;
            } else { // use max rotation
                scaleFactor = singlePlotHeight / maxRotation;
            }            
                        
            for (int j = motionList.size() - 1; j > 0; j--) {
                MotionEvent current = motionList.get(j);                                
                MotionEvent next = motionList.get(j - 1);
                int nextX = currPlotX - singleEventWidth;
                
                // get the accel or rotation value for current and next event based on index (0-5)
                float currVal = current.getValAtIndex(i);
                float nextVal = next.getValAtIndex(i);
                
                
                                
                line(currPlotX, midPoint + (currVal * scaleFactor), nextX, midPoint + (nextVal * scaleFactor));
                currPlotX = nextX;
            }
        }                        
        
        plotStartY += singlePlotHeight + plotPaddingY;
        currPlotX = plotStartX;        
    }    
}
 
// void receive( byte[] data ) {            // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
   
   
  // get the "real" message =
  String message = new String( data );
  
  String[] parts = split(message, ",");
  if (parts.length >= 8) {  
      MotionEvent motionEvent = new MotionEvent();  
      
      motionEvent.timestamp = Double.parseDouble(parts[0]);
      motionEvent.accelX = Float.parseFloat(parts[1]);
      motionEvent.accelY = Float.parseFloat(parts[2]);
      motionEvent.accelZ = Float.parseFloat(parts[3]);
      motionEvent.rotationX = Float.parseFloat(parts[4]);
      motionEvent.rotationY = Float.parseFloat(parts[5]);
      motionEvent.rotationZ = Float.parseFloat(parts[6]);
      motionEvent.marker = parts[7];
      
      if (motionEvent.accelX > maxAccel) {
          maxAccel = motionEvent.accelX;
      }
      if (motionEvent.accelY > maxAccel) {
          maxAccel = motionEvent.accelY;
      }      
      if (motionEvent.accelZ > maxAccel) {
          maxAccel = motionEvent.accelZ;
      }
      if (motionEvent.rotationX > maxRotation) {
          maxRotation = motionEvent.rotationX;
      }
      if (motionEvent.rotationY > maxRotation) {
          maxRotation = motionEvent.rotationY;
      }
      if (motionEvent.rotationZ > maxRotation) {
          maxRotation = motionEvent.rotationZ;
      }
      
      
      
      motionList.add(motionEvent);
      
      if (motionList.size() > MOTION_EVENT_BUFFER_SIZE) {
          motionList.subList(0, motionList.size() - MOTION_EVENT_BUFFER_SIZE).clear();
          //motionList.removeRange(0, motionList.size() - MOTION_EVENT_BUFFER_SIZE);
      }
            
      println("motionList size: " + motionList.size() + " MaxAccel: " + maxAccel + " MaxRotation: " + maxRotation);
  }
  
  
  /*
  String[] parts = split(message, "&");
  
  int sentX = int(parts[0]);
  int sentY = int(parts[1]);    //"24" -> 24
   
   
  line(width-sentX , sentY , random(0, 480), 0);
  stroke (random(0, 150));
 
   
  // print the result
  println( "receive: x = \""+sentX+"\" y = \""+sentY+"\"");
  */
}


void keyPressed() {
    String statusString = udp.isClosed() ? "Closed" : "Open";
    println("Socket is: " + statusString + " on " + udp.address());
}

 
