FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

LABEL maintainer="Sebastian Ramirez <tiangolo@gmail.com>"

# Install buildpack-deps:latest with its base image parts, as it is the base for official Python

# buildpack-deps:curl https://github.com/docker-library/buildpack-deps/blob/master/stretch/curl/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi
# End buildpack-deps:curl

# buildpack-deps:scm https://github.com/docker-library/buildpack-deps/blob/master/stretch/scm/Dockerfile

# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get install -y --no-install-recommends \
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		\
		procps \
	&& rm -rf /var/lib/apt/lists/*

# End buildpack-deps:scm

# buildpack-deps:latest https://github.com/docker-library/buildpack-deps/blob/master/stretch/Dockerfile

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		dpkg-dev \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgdbm-dev \
		libgeoip-dev \
		libglib2.0-dev \
		libgmp-dev \
		libjpeg-dev \
		libkrb5-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		unzip \
		xz-utils \
		zlib1g-dev \
		\
# https://lists.debian.org/debian-devel-announce/2016/09/msg00000.html
		$( \
# if we use just "apt-cache show" here, it returns zero because "Can't select versions from package 'libmysqlclient-dev' as it is purely virtual", hence the pipe to grep
			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
				echo 'default-libmysqlclient-dev'; \
			else \
				echo 'libmysqlclient-dev'; \
			fi \
		) \
	; \
	rm -rf /var/lib/apt/lists/*

# End buildpack-deps:latest

ENV PYTHON_VERSION=3.6

# Conda, fragments from: https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
# Explicit install of Python 3.7 with:
# /opt/conda/bin/conda install -y python=$PYTHON_VERSION && \
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.12-Linux-x86_64.sh -O ~/miniconda.sh 
RUN  /bin/bash ~/miniconda.sh -b -p /opt/conda 
RUN    rm ~/miniconda.sh
RUN    /opt/conda/bin/conda update -n root conda 
RUN    /opt/conda/bin/conda install -y python=$PYTHON_VERSION 
RUN    /opt/conda/bin/conda clean -tipsy 
RUN    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# End Conda


RUN conda create --name dmm _libgcc_mutex=0.1=main \
blas=1.0=mkl \
ca-certificates=2019.5.15=1 \ 
certifi=2019.6.16=py37_1 \
cffi=1.12.3=py37h2e261b9_0 \
cudatoolkit=10.0.130=0 \
freetype=2.9.1=h8a8886c_1 \
intel-openmp=2019.4=243 \
jpeg=9b=h024ee3a_2 \
libedit=3.1.20181209=hc058e9b_0 \
libffi=3.2.1=hd88cf55_4 \
libgcc-ng=9.1.0=hdf63c60_0 \
libgfortran-ng=7.3.0=hdf63c60_0 \
libpng=1.6.37=hbc83047_0 \
libstdcxx-ng=9.1.0=hdf63c60_0 \
libtiff=4.0.10=h2733197_2 \
mkl=2019.4=243 \
mkl-service=2.0.2=py37h7b6447c_0 \
mkl_fft=1.0.14=py37ha843d7b_0 \
mkl_random=1.0.2=py37hd81dba3_0 \
ncurses=6.1=he6710b0_1 \
ninja=1.9.0=py37hfd86e86_0 \
numpy=1.16.4=py37h7e9f1db_0 \
numpy-base=1.16.4=py37hde5b4d6_0 \
olefile=0.46=py37_0 \
openssl=1.1.1c=h7b6447c_1 \
pillow=6.1.0=py37h34e0f95_0 \
pip=19.2.2=py37_0 \
pycparser=2.19=py37_0 \
python=3.7.4=h265db76_1 \
pytorch=1.1.0=py3.7_cuda10.0.130_cudnn7.5.1_0 \
pytorch-nightly=1.0.0.dev20190328=py3.7_cuda10.0.130_cudnn7.4.2_0 \
#pytorch \
#pytorch-nightly \
readline=7.0=h7b6447c_5 \
scipy=1.2.1=py37h7c811a0_0 \
setuptools=41.0.1=py37_0 \
six=1.12.0=py37_0 \
sqlite=3.29.0=h7b6447c_0 \
tk=8.6.8=hbc83047_0 \
torchvision=0.3.0=py37_cu10.0.130_1 \
#torchvision=0.3.0 \
wheel=0.33.4=py37_0 \
xz=5.2.4=h14c3975_4 \
zlib=1.2.11=h7b6447c_3 \
zstd=1.3.7=h0b5b093_0 \
 -c pytorch -c conda-forge

#RUN pip install numpy matplotlib
RUN pip install numpy
RUN pip install cython
RUN pip install pycocotools pyyaml yacs opencv-python scikit-image easydict prettytable lmdb tabulate tqdm munkres tensorboardX

#RUN pip install scipy==1.1.0 --user
RUN pip install ninja yacs cython matplotlib easydict prettytable tabulate tqdm ipython scipy opencv-python networkx scikit-image tensorboardx cython scipy pillow h5py lmdb PyYAML
#RUN conda install pytorch torchvision cudatoolkit=9.2 -c pytorch
#RUN conda install pytorch torchvision cudatoolkit=9.2 -c pytorch

# Tini: https://github.com/krallin/tini
#ENV TINI_VERSION v0.18.0
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
#RUN chmod +x /tini
#ENTRYPOINT ["/tini", "--"]
# End Tini

#COPY ./start.sh /start.sh
#RUN chmod +x /start.sh


#CMD [ "/start.sh" ]

WORKDIR /workspace
RUN chmod -R a+w .
