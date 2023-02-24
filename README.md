# Scoring Functions Bias
This repository contains the code used to perform the experiments in the article "Identifying bias in network cluster quality metrics" by Martí Renedo Mirambell and Argimiro Arratia.

The code is structured as follows:
- For the single-level experiments, [single_level_computation.R](single_level_computation.R) performs de experiments, saves the results to [scores_table.RData](scores_table.RData), and [single_level_analysis.R](single_level_analysis.R) builds the table (table 3 in the article).
- For the multi-level case, [multi_level_SBM_computation.R](multi_level_SBM_computation.R) and [multi_level_BA_computation.R](multi_level_BA_computation.R) perform the experiments, and [multi_level_analysis.R](multi_level_analysis.R) builds the plots (figures 3 and 6 in the article). These plots are saved in [./plots](plots).

The implementations of the scoring functions and the multi-level preferential attachment models are part of the clustAnalytics R package.
