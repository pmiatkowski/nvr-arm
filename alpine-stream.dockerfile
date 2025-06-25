FROM arm64v8/alpine:3.14

RUN apk update \
	&& apk add curl \
	&& apk add v4l-utils \
	&& apk add libva-dev \
	&& apk add ffmpeg


#CMD ["ffmpeg -f v4l2 -input_format yuyv422 -i $DEVICE -s 640x480 -r 15 -c:v libx264 -preset ultrafast -f rtsp $RTSP_URL"]
ENTRYPOINT ["sh", "-c", "ffmpeg -f v4l2 -input_format yuyv422 -i $DEVICE -s $RESOLUTION -r $FRAME_RATE -c:v libx264 -preset ultrafast -bufsize 1M -b:v 500k -f rtsp $RTSP_URL"]

