# Streaming tools

This package contains **Motioneye** and [**Mediamtx**](https://github.com/bluenviron/mediamtx?tab=readme-ov-file) containers configured to work on *AllWinner Orange Pi Zero 2 W* device.

Mediamtx is used to stream video via RTSP protocol.

Motioneye is optional, but can be configured to intercept stream on rtsp protocol. Might be usefull if you don't have anything else in your network, like Frigate.

## Network

Initial setup assumes that one can set it up to stream video via Multicast UDP protocol and due to dynamic port changes it will work only on host network `network_mode: host`.

## Optional FFMPEG container

This is an independed lightweight streaming with ffmpeg. It can be used instead of direct invocation of ffmpeg command in the mediamtx.xml file.
Its good if you don't want to install ffmpeg libraries on the device or you don't want to use the built-in ffmpeg in the mediamtx

### Add this to the docker-compose.yml file

```yaml
 alpine-stream:
   build:
     context: .
     dockerfile: alpine-stream.dockerfile
   container_name: stream
   restart: unless-stopped
   devices:
     - /dev/video1:/dev/video1
   environment:
     - RESOLUTION=1280x1024
     - FRAME_RATE=5
     - DEVICE=/dev/video1
     - RTSP_URL=rtsp://localhost:8554/stream

   depends_on:
     - mediamtx
   networks:
     - stream_network

networks:
  stream_network:
    external: true
```

## Useful commands

- `sudo apt install v4l-utils -y` - to get details about your camera
- `v4l2-ctl --list-devices` - list connected devices
- `v4l2-ctl --list-formats-ext -d /dev/video1` - lists camera capabilities - screen resolution, format, framerate. Make sure to change `/dev/video{X}` to your camera
- `v4l2-ctl --list-ctrls` - check codec controls
- `ip maddr` - multicast addresses
- `sudo ip route add 239.255.1.2/32 dev wlan0` - add multicast address manually (optional)
- `tcpdump -i wlan0 host 239.255.1.2` - validate streamed packets

### Debugging

- `journalctl -p err` - view loged system errors
- `dmesg | grep -i ABC` - check for messages in the kernel ring buffer
- `top -o %CPU | head -n12` - shows the top 12 CPU consumig process
- `find / -size +10M`  - finds files/directories larger thatn 10megabytes on the entire file system
- `watch -n 5 free -m` - monitors memory usage every 5 seconds
- `du -cha --max-depth=1 / | grep -E "M|G"` - displays disk usage for directories at the top level of the file system and filters the output to show only entries with sizes in megabytes (M) or gigabytes (G)

## Examples

### UDP Multicast stream

Works well with ethernet connection or 5Ghz WIFI connection. I was unable to make it work on 2.4GHz WIFI connection. My Asus router (with AI Mesh) was streaming packets only for a few seconds after router boot. Then packets were lost (tested on Raspberry Pi Zero 2 W, does not support 5GHz)

`ffmpeg -f v4l2 -input_format yuyv422 -i /dev/video1 -s 1024x768 -r 15 -c:v libx264 -preset ultrafast -f mpegts udp://239.255.1.2:5000?ttl=64`

### Restream Multicast to RTSP

`ffmpeg -i udp://239.255.1.2:5000 -c copy -f rtsp rtsp://localhost:8554/live`
