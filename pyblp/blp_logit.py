# This code is taken directly from the pyBLP logit tutorial with minimal modifications: https://pyblp.readthedocs.io/en/stable/_notebooks/tutorial/logit_nested.html

import pyblp
import numpy as np
import pandas as pd
import statsmodels as sm
import statsmodels.regression.linear_model as smrl

# Setting up the options for pyblp
pyblp.options.digits = 2
pyblp.options.verbose = False

def run_linear_model():
    # Read in the product dvata
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

    # Print the regression summary
    print("==============================================================================")
    print("===== Running Linear Regression with statsmodel                               ")
    print("==============================================================================")
    print("")
    print(results.summary())

    # The same magnitude price increase for a Yugo and BMW decrease demand equivalently
    price_change = 0.02  # Change in car price
    price_change_coefficient = results.params['prices']  # Coefficient for prices variable

    # Assuming a Yugo and a BMW both have the same values for other predictors,
    # their changes in the dependent variable (dif_2) would be the same.
    yugo_change = price_change * price_change_coefficient
    bmw_change = price_change * price_change_coefficient

    print("Change in dif_2 for Yugo:", yugo_change)
    print("Change in dif_2 for BMW:", bmw_change)

    print("==============================================================================")
    print("")

def run_logit_model():

    product_data = pd.read_csv(pyblp.data.BLP_PRODUCTS_LOCATION)

    logit_formulation = pyblp.Formulation('prices + hpwt + air + mpd + space', absorb=None)
    print("======================================================================")
    print("===== Running Logit Model in BLP                                      ")
    print("======================================================================")
    print("")
    print("===== Formulation                                                     ")
    print(logit_formulation)
    print("")

    problem = pyblp.Problem(logit_formulation, product_data)
    print("===== Problem Details                                                 ")
    print(problem)
    print("")

    logit_results = problem.solve()
    print("===== Results                                                         ")
    print("")
    print(logit_results)
    print("")
    print("======================================================================")
    print("")


if __name__ == "__main__":
    run_linear_model()
    run_logit_model()

