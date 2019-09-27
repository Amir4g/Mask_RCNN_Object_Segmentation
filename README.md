# DMM-Net: Differentiable Mask-Matching Network for Video Object Segmentation (ICCV 2019)

[paper.pdf](https://www.cs.toronto.edu/~xiaohui/dmm/paper/dmmnet_iccv19.pdf)

## Overview
![model](data/paper_figures/model.png)

### Requirements:
- PyTorch 1.1.0 
- matplotlib 3.0.2
- maskrnn-benchmark
- not in requirements.txt:
    - cython 
    - pycocotools # (2.0-py3.7-linux-x86_64)
    - pyyaml yacs
    - opencv-python scikit-image
    - easydict prettytable lmdb tabulate

## Installation 
- Follow [INSTALL.md](INSTALL.md)

## Data

### YouTube-VOS

- Download the YouTube-VOS dataset from their [website](https://youtube-vos.org/dataset/vos/). 
Please note that our code is trained and tested only on YouTube-VOS dataset for 2018 version. There is a newer version released 2019 but it is not tested. 

- We recommend to symlink the path to the youtube dataset to datasets/ as follows
```
cd datasets 
ln -s path/to/youtubeVOS youtubeVOS 
```

- The files structure should look like:
```
DMM/datasets 
       ├── youtubeVOS
       │       ├── train 
       │       │      ├── JPEGImages
       │       │      │        ├── ... 
       │       │      ├── Annotations 
       │       │      │        ├── ... 
       │       ├── valid 
       │       │      ├── JPEGImages
       │       │      │        ├── ... 
       │       │      ├── Annotations 
       │       │      │        ├── ... 
       │       ├── train_testdev_ot (optional)
       │       │      ├── JPEGImages
       │       │      │        ├── ... 
       │       │      ├── Annotations 
       │       │      │        ├── ... 
```

## Prepare proposals 

### Option1: Download the extracted file

#### for evaluation
- To eval DMMnet on youtubeVOS with the fine-tuned proposal net, use the propsoals generated by our fine-tuned Mask R-CNN model:
    - [proposals-train-val](https://www.cs.toronto.edu/~xiaohui/proposals_ytb_train.tar.gz)
    ```  
    mkdir -p experiments/proposals/ 
    cd experiments/proposals/  
    wget https://www.cs.toronto.edu/~xiaohui/proposals_ytb_train.tar.gz
    tar xzf proposals_ytb_train.tar.gz 
    ```

#### for training 
- To train the DMMnet on youtubeVOS train-train split, need to prepare 1. proposals for both train-train and train-val split extracted by coco pretrained X101 Mask R-CNN model 
- proposals can be downloaded: 
    - [proposals_coco81 (train-train, train-val and testdev-online-training)](http://www.cs.toronto.edu/~xiaohui/feature_coco81.tar.gz)
     ``` 
      mkdir -p experiments/proposals/  
      cd experiments/proposals/ 
      wget http://www.cs.toronto.edu/~xiaohui/feature_coco81.tar.gz
      tar xzf feature_coco81.tar.gz 
     ```

- preprocess the proposals for training DMM: 
```
python tools/reduce_pth_size_by_videos.py  experiments/proposals/coco81/inference/youtubevos_train3k_meta/predictions.pth  train 50
python tools/reduce_pth_size_by_videos.py  experiments/proposals/coco81/inference/youtubevos_val200_meta/predictions.pth  trainval 50
python tools/reduce_pth_size_by_videos.py  experiments/proposals/coco81/inference/youtubevos_testdev_online_meta/predictions.pth  train_testdev_ot 90 
```

- The files structure should look like:
```
DMM/experiments
       ├── propnet
       │     ├── join_ytb_bin
       │     │       ├── model_0172500.pth 
       │     ├── online_ytb
       │     │       ├── model_0225000.pth 
       ├── dmmnet 
       │     ├── ytb_255_50_matchloss_epo13
       │     │       ├── epo13_iter01640
       │     ├── ytb_255_50
       │     │       ├── epo08_iter01640
       │     ├── online_ytb
       │     │       ├── epo101 
       ├── proposals 
       │     ├── coco81 
       │     │     ├── inference
       │     │     │       ├── youtubevos_train3k_meta (optional)
       │     │     │       ├── youtubevos_val200_meta
       │     │     │       ├── youtubevos_testdev_online_meta (optional)
       │     ├── ytb_train 
       │     │     ├── inference
       │     │     │       ├── youtubevos_val200_meta
       │     ├── ytb_ot 
       │     │     ├── inference
       │     │     │       ├── youtubevos_testdev_meta
```

### Option2: extract the proposals 
- The model trained on youtubeVOS dataset can be found in [MODEL_ZOO.md](./MODEL_ZOO.md)
- The scripts used to extract proposals from the trained model can be found in [scripts/extract/](./scripts/extract)

## Training
- Train DMMnet on youtubeVOS: 
```
sh scripts/train/train_load_prop.sh
```

### Online training
Train DMMnet on the first frame of validation set, 

- first download the preprocessed data used for online training from [here](https://hkustconnect-my.sharepoint.com/:u:/g/personal/xzengaf_connect_ust_hk/ETsB6vt5U51Npzwcamb67YMBKPjC4tl5ONBilpFPTmsQyA?e=QN1VjA), extract the data and put/link the extracted folder as `/PATH/TO/datasets/youtubeVOS/train_testdev_ot`

- prepare proposal, check the Section: Prepare proposals - for training 

- get the DMMnet trained on train-train set for 1 epoch from [here](https://hkustconnect-my.sharepoint.com/:u:/g/personal/xzengaf_connect_ust_hk/ESmFqlodogNLrEIMt0ve84IBAOVokxY5HTDG3YMVQ5dzbg?e=6K4VY2) and put it under `experiments/dmmnet/` 

- start online training 
```
sh scripts/train/train_online.sh # it takes ~0.17h for one epoch
```

## Evaluation
- Evaluate DMMnet on trainval split: 
    - will need the trained model and the extracted train-val proposal: 
    ```
    cd ./experiments/dmmnet/
    wget http://www.cs.toronto.edu/~xiaohui/dmm/models/dmmnet_ytb_255_50_matchloss_epo13.tar.gz 
    tar xzf dmmnet_ytb_255_50_matchloss_epo13.tar.gz 
    wget http://www.cs.toronto.edu/~xiaohui/dmm/models/dmmnet_ytb_255_50.tar.gz 
    tar xzf dmmnet_ytb_255_50.tar.gz
    cd ../../ 

    cd ./experiments/proposals/ 
    wget http://www.cs.toronto.edu/~xiaohui/dmm/proposals/proposals_ytb_train.tar.gz
    tar xzf proposals_ytb_train.tar.gz 
    cd ../../
    ```
    - run `sh scripts/eval/eval_r50.sh` 
    - compute the J and F score by `sh scripts/metric/full_eval.sh /PATH/TO/OUTPUT/merged/`
    expected results:
    
| Method   |   J_mean |   J_recall |   J_decay |   F_mean |   F_recall |   F_decay |
|-------------|----------|------------|-----------|----------|------------|-----------|
| ytb_R50_w_match_loss_epo13 [model: ytb_255_50_matchloss_epo13](https://hkustconnect-my.sharepoint.com/:u:/g/personal/xzengaf_connect_ust_hk/ERgj1R97zEFAm1RC-8fsw1wBcP3Lre4zI-ArDiDdmEjBYA?e=SIqAqZ) | 0.611 | 0.702 | 0.104 |0.747 | 0.824 |     0.111 |
| ytb_R50_wo_match_loss_epo08 [model: ytb_255_50](https://hkustconnect-my.sharepoint.com/:u:/g/personal/xzengaf_connect_ust_hk/ERQB9zbqRLxFvjTkEZgWSsoBswr2Xxvk6vQqnx8S7TPjqg?e=QyIEG3) |      0.6 |      0.684 |     0.104 |    0.742 |      0.819 |     0.109 |

- Evaluate online-trained DMMnet:
    - Download proposals extracted by online-trained proposal net: 
    ```
    cd ./experiments/proposals/
    wget http://www.cs.toronto.edu/~xiaohui/dmm/proposals/proposals_ytb_ot.tar.gz 
    tar xzf proposals_ytb_ot.tar.gz 
    cd ../../
    ```
    - Download model:
    ```
    cd experiments/dmmnet/
    wget http://www.cs.toronto.edu/~xiaohui/dmm/models/dmmnet_online_ytb.tar.gz 
    tar xzf dmmnet_online_ytb.tar.gz 
    cd ../../
    ```
    - run `scripts/eval/eval_testdev.sh`
    - prepare the submission data with `scripts/submit.sh` and submit to [the server](https://competitions.codalab.org/competitions/19544#learn_the_details), expected resules: G mean = 0.579
    
-----------
part of the code is from https://github.com/imatge-upc/rvos