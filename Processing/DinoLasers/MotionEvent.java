public class MotionEvent {
    
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
}