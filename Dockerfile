FROM nvcr.io/nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update \
 && DEBIAN_FRONTEND=noninteractive apt-get -qqy install python3-pip cmake python3-dev python3-opencv pkg-config libjpeg-dev libpng-dev libtiff-dev libgtk-3-dev python3-numpy webp libopencv-dev ffmpeg git less nano libsm6 libxext6 libxrender-dev \
 && rm -rf /var/lib/apt/lists/*

RUN git clone -b '4.4.0' --single-branch --depth 1 https://github.com/opencv/opencv.git && \
    git clone -b '4.4.0' --single-branch --depth 1 https://github.com/opencv/opencv_contrib.git && \
    cd opencv && mkdir -p build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D INSTALL_C_EXAMPLES=ON \
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D BUILD_EXAMPELS=OFF .. && \
    make -j7 && \
    make install

COPY requirements.txt /app/requirements.txt
WORKDIR /app

RUN pip3 install --upgrade pip
RUN pip3 install \
  https://download.pytorch.org/whl/cu100/torch-1.0.0-cp36-cp36m-linux_x86_64.whl \
  git+https://github.com/1adrianb/face-alignment \
  -r requirements.txt
COPY . .
ENTRYPOINT python3 fom.py --config config/vox-adv-256.yaml --checkpoint models/vox-adv-cpk.pth.tar --relative --adapt_scale

