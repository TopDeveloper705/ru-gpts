#! /bin/bash

# Model parallel size
MP_SIZE=1
# Change for multinode config
NUM_WORKERS=1
NUM_GPUS_PER_WORKER=1

script_path=$(realpath $0)
script_dir=$(dirname $script_path)
now=$(date +"%Y_%m_%d_%H_%I_%S")
host=$(hostname)

config_json="$script_dir/deepspeed_config/gpt3_small_2048.json"
gpt_options=" \
       --test-data-path /home/jovyan/datasets/unpacked/gpt3_zmitrovich/test_books_only \
       --load /home/jovyan/models/gpt3/deepspeed/small/finetune_dense_seq2048_b256_exp2 \
       --tokenizer-path /home/jovyan/datasets/unpacked/gpt3_zmitrovich/_tokenizer \
       --max-files-per-process 50000 \
       --no-load-optim \
       --model-parallel-size ${MP_SIZE} \
       --num-layers 12 \
       --hidden-size 768 \
       --num-attention-heads 12 \
       --batch-size 16 \
       --seq-length 2048 \
       --max-position-embeddings 2048 \
       --distributed-backend nccl \
       --log-interval 10 \
       --fp16 \
       --deepspeed \
       --deepspeed_config ${config_json} \
"

run_cmd="mpirun --np ${NUM_GPUS_PER_WORKER} python ${script_dir}/../../deepspeed_megatron/pretrain_gpt3.py $@ ${gpt_options}"
echo ${run_cmd}
eval ${run_cmd}

set +x
