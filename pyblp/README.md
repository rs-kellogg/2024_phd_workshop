# Set up local git repository
## First time to use this git repository
```
git clone https://github.com/rs-kellogg/2024_phd_workshop
```
## Already cloned repository previously: pull latest updates from github
```
cd 2024_phd_workshop
git pull
```


# Load pyblp_env mamba environment
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
```


# Run IPython notebook on Quest
```
# Install kernel for use on Quest ipython notebook (need to install once, then kernel will be available in subsequent sesssions)
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
python -m ipykernel install --user --name pyblp_env --display-name "Python (pyblp_env)"
```
- Quest analytic node  
https://jupyter.questanalytics.northwestern.edu  
Select the "Python (pyblp_env)" kernel before you run cells

- Launch the jupyter notebook in FastX on KLC
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
jupyter notebook --browser=firefox
```  


# Use knitro optimizer
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
module load knitro/12.4
cd 2024_phd_workshop
cd pyblp
python blp_optimizer.py --opt_method knitro
```
