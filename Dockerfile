# Set the base image to Ubuntu
FROM ubuntu:latest

# File Author / Maintainer
MAINTAINER Bill Lee, lee.minwee@gmail.com

#install samtools
RUN apt-get update && \
    apt-get install -y \
      libncurses5-dev \
      libncursesw5-dev \
      build-essential \
      zlib1g-dev \
      libbz2-dev \
      liblzma-dev \
      pigz wget git make gcc python-dev build-essential python-pip zlib1g-dev && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install --upgrade pip==9.0.3 && pip install -U pip setuptools matplotlib numpy && wget https://bootstrap.pypa.io/ez_setup.py -O - | python

ENV ZIP=samtools-1.3.tar.bz2
ENV URL=https://github.com/samtools/samtools/releases/download/1.3
ENV FOLDER=samtools-1.3
ENV DST=/tmp

RUN mkdir /opt/samtools

RUN wget $URL/$ZIP -O $DST/$ZIP && \
    tar xvf $DST/$ZIP -C $DST && \
    rm $DST/$ZIP && \
    cd $DST/$FOLDER && \
    make && \
    make prefix=/opt/samtools install && \
    cd / && \
    rm -rf $DST/$FOLDER

#install bcftools
ENV ZIP=bcftools-1.3.1.tar.bz2
ENV URL=https://github.com/samtools/bcftools/releases/download/1.3.1
ENV FOLDER=bcftools-1.3.1
ENV DST=/tmp

RUN mkdir /opt/bcftools

RUN wget $URL/$ZIP -O $DST/$ZIP && \
    tar xvf $DST/$ZIP -C $DST && \
    rm $DST/$ZIP && \
    cd $DST/$FOLDER && \
    make && \
    make prefix=/opt/bcftools install && \
    cd / && \
    rm -rf $DST/$FOLDER

ENV PATH="/opt/bcftools/bin:/opt/samtools/bin:${PATH}"

#install gsl (needed for gemBS)
ENV ZIP=gsl-latest.tar.gz
ENV FOLDER=gsl-2.4
ENV DST=/tmp
RUN wget http://mirror.rise.ph/gnu/gsl/$ZIP -O $DST/$ZIP && \
    tar xvf $DST/$ZIP -C $DST && \
    rm $DST/$ZIP && \
    cd $DST/$FOLDER && \
    ./configure && make && make install && \
    cd / && \
    rm -rf $DST/$FOLDER

#install gemBS
RUN git clone --recursive https://github.com/heathsc/gemBS.git /opt/gemBS
RUN sed -i -e " s|GSL_LIB = -L.*|GSL_LIB = -L/usr/local/lib/|" /opt/gemBS/tools/bs_call/Gsl.mk && \
    sed -i -e " s|GSL_INC = -I.*|GSL_INC = -L/usr/local/include/gsl/|" /opt/gemBS/tools/bs_call/Gsl.mk && \
    cd /opt/gemBS && python setup.py install

RUN apt-get update && apt-get install -y gsl-bin libgsl-dev bison flex

#install bigwig
RUN cd /home && wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/wigToBigWig && \
    chmod +x wigToBigWig && cp wigToBigWig /usr/local/bin

RUN mkdir /data
WORKDIR /data
