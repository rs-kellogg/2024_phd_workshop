

# Load pyblp_env mamba environment
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
```


# Run IPython notebook on Quest
```
# Install kernel for use on Quest ipython notebook
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
python -m ipykernel install --user --name pyblp_env --display-name "Python (pyblp_env)"
```
- [Quest analytic node](jupyter.questanalytics.northwestern.edu/hub/login)  
Select the "Python (pyblp_env)" kernel before you run cells

- Launch the jupyter notebook in FastX  
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
jupyter notebook --browser=firefox
# Select the "Python (pyblp_env)" kernel before you run cells
```  


# Use knitro optimizer
```
module load mamba/23.1.0
source activate /kellogg/software/envs/pyblp_env
module load knitro/12.4
python blp_optimizer.py --opt_method knitro
```
