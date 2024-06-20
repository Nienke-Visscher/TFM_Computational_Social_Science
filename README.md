# TFM Computational Social Science
The aim of this thesis will be to predict consumption patterns of foodstuffs in Spain by autonomous community, sales channel and product type. The main data set that is used for modeling these predictions contains time-series data starting in 2018 until 2024 per autonomous community including information on:
The sales channel (Tradicional, Cash & Carry, Droguerías, Hypermarket, Others (small stores) and Online)
The equivalent unit consumed per product type.
The data that is uploaded in this repository is only a random sample as the data should not be disclosed. The file name for this data set is ‘Data’.
This main data set is  enriched by including longitudinal data obtained from the Instituto Nacional de Estadistica on to enhance the predictive performance. This data will include:
GDP per autonomous community
Production aggregation of the 1) wholesale and retail trade; 2) repair of motor vehicles and motorcycles; 3) transportation and storage; and 4) accommodation and food service activities
These data sets are named ‘’
The full data set including the external data was generated using the .RMD.
The descriptive visualisations are included the file descriptive_visualisations.r
The file ‘machine_learning_forecasting.RMD’ contains the code for training the machine learning models to predict the consumption of foodstuffs. In the RMD two predictive models are built: a global model including Decision Tree, Random Forest and Prophet as well as a well tuned Prophet model.
The machine learning models utilised in the global model are included in the package ‘Modeltime’ in R. This package is an extension to the ’Tidymodels’ ecosystem targeted at time-series models. The package functions with the following workflow: 1) Creating a modeltime table, 2) Calibrating the model by performing forecasting in the train set and consequently testing the accuracy, and 3) Refitting and forecasting the future. The finely tuned Prophet model is done using the original Prophet package by Facebook. 
The final thesis document is called: TFM_RN_Visscher.pdf

