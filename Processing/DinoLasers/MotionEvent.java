public class MotionEvent {
    
    public static final int NUM_MOTION_VALS = 6;
    
    public float accelX, accelY, accelZ, rotationX, rotationY, rotationZ;
    public double timestamp;
    public String marker;
    
    
    public float getValAtIndex(int index) {
        float val = 0;
        switch (index) {
            case 0:
            val = accelX;
            break;
            case 1:
            val = accelY;
            break;
            case 2:
            val = accelZ;
            break;
            case 3:
            val = rotationX;
            break;
            case 4:
            val = rotationY;
            break;
            case 5:
            val = rotationZ;
            break;
        }
        return val;
    }
    
    public void setValAtIndex(int index, float val) {
        switch (index) {
            case 0:
            this.accelX = val;
            break;
            case 1:
            this.accelY = val;
            break;
            case 2:
            this.accelZ = val;
            break;
            case 3:
            this.rotationX = val;
            break;
            case 4:
            this.rotationY = val;
            break;
            case 5:
            this.rotationZ = val;
            break;
        }
    }
    
    public void copyValuesFromMotionEvent(MotionEvent motionEvent) {
        this.timestamp = motionEvent.timestamp;
        this.marker = motionEvent.marker;
        
        for (int i = 0; i < NUM_MOTION_VALS; i++) {
            setValAtIndex(i, motionEvent.getValAtIndex(i));
        }
    }
    
    public static MotionEvent lowPassResult(MotionEvent motionEvent, MotionEvent refMotionEvent, float alpha) {
        
        MotionEvent returnEvent = new MotionEvent();
        
        if (motionEvent == null && refMotionEvent != null) {
            returnEvent.copyValuesFromMotionEvent(refMotionEvent);
        }
                
        if (motionEvent != null && refMotionEvent != null) {
            for (int i = 0; i < NUM_MOTION_VALS; i++) {
                float filteredVal = (float)((motionEvent.getValAtIndex(i) * alpha) + (refMotionEvent.getValAtIndex(i) * (1.0 - alpha)));                
                returnEvent.setValAtIndex(i, filteredVal);                
            }
        }        
        return returnEvent;
    }
}