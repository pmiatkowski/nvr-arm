#!/bin/sh

echo "Detecting camera device using udevadm..."

# Function to get device name using udevadm
get_device_name() {
    local device="$1"
    udevadm info --query=property --name="$device" 2>/dev/null | grep "ID_V4L_PRODUCT=" | cut -d'=' -f2
}

# Function to get device attributes
get_device_attrs() {
    local device="$1"
    udevadm info --attribute-walk --name="$device" 2>/dev/null | grep 'ATTRS{product}' | head -1 | cut -d'"' -f2
}

# Scan for video devices and check their attributes
for dev in /dev/video*; do
    if [ -c "$dev" ]; then
        device_name=$(get_device_name "$dev")
        device_attrs=$(get_device_attrs "$dev")
        
        echo "Device: $dev"
        echo "  Name: $device_name"
        echo "  Attrs: $device_attrs"
        
        # Check for USB Camera or similar patterns
        if echo "$device_name $device_attrs" | grep -qi "USB Camera\|UVC\|Webcam\|Camera"; then
            echo "Found USB Camera at $dev"
            echo "Starting stream with device: $dev"
            
            
            # # Execute ffmpeg command to stream the video
            exec ffmpeg -f v4l2 -input_format mjpeg -video_size 1600x900 -r 7 -i "$dev" \
                        -c:v libx264 -preset ultrafast -b:v 1000k -maxrate 1000k -bufsize 2000k \
                        -f rtsp rtsp://localhost:$RTSP_PORT/$MTX_PATH;

         
        fi
    fi
done

echo "No suitable video device found!"
exit 1