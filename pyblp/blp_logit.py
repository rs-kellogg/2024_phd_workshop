# This code is taken directly from the pyBLP logit tutorial with minimal modifications: https://pyblp.readthedocs.io/en/stable/_notebooks/tutorial/logit_nested.html

import pyblp
import numpy as np
import pandas as pd
import statsmodels as sm
import statsmodels.regression.linear_model as smrl
import os
import time

# Setting up the options for pyblp
pyblp.options.digits = 2
pyblp.options.verbose = False

def run_linear_model(output_file):
    # read in the product dvata
    product_data = pd.read_csv(pyblp.data.BLP_PRODUCTS_LOCATION)

    # Calculate the share_out variable
    product_data['share_out'] = 1.0 - product_data.groupby('market_ids')['shares'].transform('sum')

    # Calculate the dif_2 variable as in the original paper
    # dif_2 represents the logarithmic difference between the market share of a specific product and the share of 
    # the outside option in a given market.
    product_data['dif_2'] = np.log(product_data['shares']) - np.log(product_data['share_out'])

    # Define predictor variables (X) and response variable (y)
    X = product_data[["hpwt", "air", "mpd", "space", "prices"]]
    y = product_data["dif_2"]

    # Adding a constant term to the predictor variables (intercept)
    X = X.assign(intercept=1)

    # Create a linear regression model
    model = smrl.OLS(y, X)

    # Fit the model
    results = model.fit()

    with open(output_file, "a") as f:
        # Print the regression summary
        f.write("==============================================================================\n")
        f.write("===== Running Linear Regression with statsmodel\n")
        f.write("==============================================================================\n")
        f.write("\n")
        f.write(str(results.summary()))
        f.write("\n")

        # The same magnitude price increase for a Yugo and BMW decrease demand equivalently
        price_change = 0.02  # Change in car price
        price_change_coefficient = results.params['prices']  # Coefficient for prices variable

        # Assuming a Yugo and a BMW both have the same values for other predictors,
        # their changes in the dependent variable (dif_2) would be the same.
        yugo_change = price_change * price_change_coefficient
        bmw_change = price_change * price_change_coefficient

        f.write(f"Change in dif_2 for Yugo: {yugo_change}\n")
        f.write(f"Change in dif_2 for BMW: {bmw_change}\n")

        f.write("==============================================================================\n")
        f.write("\n")

def run_logit_model(output_file):

    product_data = pd.read_csv(pyblp.data.BLP_PRODUCTS_LOCATION)

    logit_formulation = pyblp.Formulation('prices + hpwt + air + mpd + space', absorb=None)
    with open(output_file, "a") as f:
        f.write("======================================================================\n")
        f.write("===== Running Logit Model in BLP\n")
        f.write("======================================================================\n")
        f.write("\n")
        f.write("===== Formulation\n")
        f.write(str(logit_formulation))
        f.write("\n\n")

        problem = pyblp.Problem(logit_formulation, product_data)
        f.write("===== Problem Details\n")
        f.write(str(problem))
        f.write("\n\n")

        logit_results = problem.solve()
        f.write("===== Results\n")
        f.write("\n")
        f.write(str(logit_results))
        f.write("\n\n")
        f.write("======================================================================\n")
        f.write("\n")


if __name__ == "__main__":
    directory_name = f"{time.strftime('%Y-%m-%d')}_logit"
    if not os.path.exists(directory_name):
        os.makedirs(directory_name)
    linear_output_file = os.path.join(directory_name, f"output_linear_{time.strftime('%Y-%m-%d_%H%M')}.txt")
    logit_output_file = os.path.join(directory_name, f"output_logit_{time.strftime('%Y-%m-%d_%H%M')}.txt")
    run_linear_model(linear_output_file)
    run_logit_model(logit_output_file)

