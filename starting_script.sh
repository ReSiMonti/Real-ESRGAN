#!/bin/bash

sudo apt update
sudo apt install software-properties-common

if [[! "$(python3.9 -V)" =~ "Python 3.9" ]]; then
  sudo add-apt-repository ppa:deadsnakes/ppa -y
  sudo apt install python3.9 -y
  sudo apt install python3.9-distutils python3.9-pip python3.9-distutils python3.9-dev python3.9-venv -y
  sudo apt-get install ffmpeg libsm6 libxext6  -y
fi

if [[ -d "./Real-ESRGAN" ]]; then
	echo "Real-ESRGAN already exists"
else
	git clone https://github.com/ReSiMonti/Real-ESRGAN.git
	wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -P ./experiments/pretrained_models
  wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.3/RealESRGAN_x4plus_netD.pth -P ./experiments/pretrained_models
  mkdir tuning_images
  gsutil -m cp gs://marazzi-tile-pattern-dev-raw-images/fine_tuning_images/FINE_TUNING/* ./tuning_images/
fi

if [[ -d "./venv" ]]; then
  source venv/bin/activate
else
  python3.9 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
fi

python3.9 setup.py develop
python3.9 scripts/extract_subimages.py --input ./tuning_images/ --output ./tuning_sub_images/ --crop_size 400 --step 200
python3.9 scripts/generate_meta_info.py --input ./tuning_sub_images/ --root . --meta_info ./meta/tuning_meta.txt

#if [[! -d "./fine-tuning-images" ]]; then
#	mkdr fine-tuning-images
#
#
#fi


