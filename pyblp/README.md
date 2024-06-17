

# Load pyblp_env mamba environment
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
```

# Use knitro optimizer
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
module load knitro/12.4
python blp_optimizer.py --opt_method knitro
```

