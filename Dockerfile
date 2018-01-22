# For Go 1.9.*
FROM golang:1.9

# Install image magick
ENV MAGICK_URL "http://imagemagick.org/download/releases"
ENV MAGICK_VERSION 6.9.9-33

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    libpng-dev libjpeg-dev libtiff-dev \
  && apt-get remove -y imagemagick \
  && cd /tmp \
  && wget "${MAGICK_URL}/ImageMagick-${MAGICK_VERSION}.tar.gz" \
  && tar xzf "ImageMagick-${MAGICK_VERSION}.tar.gz" \

# http://www.imagemagick.org/script/advanced-unix-installation.php#configure
  && cd "ImageMagick-${MAGICK_VERSION}" \
  && ./configure \
    --disable-static \
    --enable-shared \

    --with-jpeg \
    --with-openjp2 \
    --with-png \
    --with-tiff \
    --with-quantum-depth=8 \

    && make \
    && make install \
    && ldconfig /usr/local/lib \

    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd ..

# Create a directory inside the container to store all our application and then make it the working directory.
RUN mkdir -p /go/src/app
WORKDIR /go/src/app

# Copy the app directory (where the Dockerfile lives) into the container.
COPY . /go/src/app

# Download and install any required third party dependencies into the container.
RUN go-wrapper download
RUN go-wrapper install

# Expose port 80
EXPOSE 80

# Now tell Docker what command to run when the container starts
CMD ["go-wrapper", "run"]