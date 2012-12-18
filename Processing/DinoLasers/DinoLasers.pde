import hypermedia.net.*;    // import UDP library
import java.util.ArrayList.*;

UDP udp;  // define the UDP object (sets up)

ArrayList <MotionEvent> motionList;
MotionEvent lowPassReference;
float lowPassAlpha = 0.100000000;
float lowPassAlphaMin = 0.1;
float lowPassAlphaMax = 1.0;
float lowPassAlphaIncrement = 0.100000000;


public static final int MOTION_EVENT_BUFFER_SIZE = 50;

float maxAccel, maxRotation = 0;

// Reading from a file
boolean readLogFile = true;
int timerInterval = 50; // in milliseconds
int timerIntervalStart = 0;
String[] logMessages;
int currLogMessage = 0;

void setup() {
 size(700,900);
 
 background(0);
 smooth();
 
  // create a new datagram connection on port 6000
  // and wait for incoming message
  udp = new UDP( this, 10552); 
  udp.log( true );        // <-- printout the connection activity
  if (!readLogFile) {
      udp.listen( true );      
  }
  
  motionList = new ArrayList<MotionEvent>();
  
  if (readLogFile) {
      
      logMessages = loadStrings("hand_wave.csv");
      
      timerIntervalStart = millis();      
  }

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
    
    
    if (readLogFile) {
        if (millis() > timerIntervalStart + timerInterval) {
            
            if (logMessages.length > 0) {                
                if (currLogMessage >= logMessages.length) {
                    currLogMessage = 0;
                }
                
                processMotionEventMessage(logMessages[currLogMessage]);
                
                currLogMessage++;
            }             
            
            timerIntervalStart = millis();
        }
    }
    
    drawMotionPlots();
    
    // add some info about current vals
    stroke(255);
    text("low-pass alpha:  " + lowPassAlpha, 40, height - 50);
}

void drawMotionPlots() {
    int plotPaddingX = 50;
    int plotStartX = width - plotPaddingX; 
    
    int singlePlotWidth = width - 100;
    int singlePlotHeight = 100;        
    int singleEventWidth = singlePlotWidth / MOTION_EVENT_BUFFER_SIZE;
    
    int currPlotX = plotStartX;
    int plotStartY = 120;
    int plotPaddingY = 10;

    // draw line plots
    for (int i = 0; i < 6; i++) {
        
        noStroke();
        fill(100);
        rect(0 + plotPaddingX, plotStartY, width - plotPaddingX * 2, singlePlotHeight);

        switch(i) {
            case 0:
            case 3:
                stroke(255, 0, 0);
                break;
            case 1:
            case 4:
                stroke(0, 255, 0);
                break;
            case 2:
            case 5:
                stroke(0, 0, 255);
                break;
        }
        
        if (motionList.size() > 1) { // make sure we have at least two values
            
            int midPoint = plotStartY + (singlePlotHeight / 2);
            
            // create scale factor so we hopefully use the majority of the plotheight
            float scaleFactor = 1.0;
            if (i < 3) { // use max accel
                scaleFactor = (singlePlotHeight / 2) / maxAccel;
            } else { // use max rotation
                scaleFactor = (singlePlotHeight / 2) / maxRotation;
            }   
            
            //println("scaleFactor: " + scaleFactor);
                        
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

void processMotionEventMessage(String message) {
    
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

        lowPassReference = MotionEvent.lowPassResult(motionEvent, lowPassReference, lowPassAlpha);
        
        
        adjustMinMaxVals(lowPassReference);
        motionList.add(lowPassReference);

        if (motionList.size() > MOTION_EVENT_BUFFER_SIZE) {
            motionList.subList(0, motionList.size() - MOTION_EVENT_BUFFER_SIZE).clear();
        }
        //println("motionList size: " + motionList.size() + " MaxAccel: " + maxAccel + " MaxRotation: " + maxRotation);
    }
}

void adjustMinMaxVals(MotionEvent motionEvent) {
    // kinda dirty code to calculate max (doesn't ever bring range back down to match current motionList)
    if (abs(motionEvent.accelX) > maxAccel) {
        maxAccel = abs(motionEvent.accelX);
    }
    if (abs(motionEvent.accelY) > maxAccel) {
        maxAccel = abs(motionEvent.accelY);
    }      
    if (abs(motionEvent.accelZ) > maxAccel) {
        maxAccel = abs(motionEvent.accelZ);
    }
    if (abs(motionEvent.rotationX) > maxRotation) {
        maxRotation = abs(motionEvent.rotationX);
    }
    if (abs(motionEvent.rotationY) > maxRotation) {
        maxRotation = abs(motionEvent.rotationY);
    }
    if (abs(motionEvent.rotationZ) > maxRotation) {
        maxRotation = abs(motionEvent.rotationZ);
    }
}
 
// UDP Handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
   
  String message = new String( data );
  println("message: " + message);
  processMotionEventMessage(message);
  
}

// Key Event Handler
void keyPressed() {
    
    if (key == 's') { // status
        String statusString = udp.isClosed() ? "Closed" : "Open";
        println("Socket is: " + statusString + " on " + udp.address());        
    } else if (key == ',' || key == '<') { // reduce lowPassAlpha
        if (lowPassAlpha - lowPassAlphaIncrement >= lowPassAlphaMin ) {
            lowPassAlpha -= lowPassAlphaIncrement;
        } 
    } else if (key == '.' || key == '>') { // increase lowPassAlpha) 
        if (lowPassAlpha <= lowPassAlphaMax ) {
            lowPassAlpha += lowPassAlphaIncrement;
        }
    }
}

 
