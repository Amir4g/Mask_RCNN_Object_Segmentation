docker build -t name:tag Dockerfile

conda install pytorch torchvision cudatoolkit=9.2 -c pytorch

cd ..
git clone https://github.com/ZENGXH/maskrcnn-benchmark.git
cd maskrcnn-benchmark

## install pkgs
git clone https://github.com/pytorch/vision.git
cd vision
python setup.py install
cd ..
pip install cython

git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
python setup.py build_ext install
cd ../../

#change if (torch.cuda.is_available() and CUDA_HOME is not None) or os.getenv("FORCE_CUDA", "0") == "1": 
# ---> if (torch.cuda.is_available() and CUDA_HOME is not None) or os.getenv("FORCE_CUDA", "0") == "1":

# build maskrcnn-benchmark 
python setup.py build develop

pip install pycocotools pyyaml yacs opencv-python scikit-image easydict prettytable lmdb tabulate tqdm munkres tensorboardX

