
# aiexplainr

<!-- badges: start -->
<!-- badges: end -->

Use large language models (LLMs) like GPT-4 to explain model results in R. It has been tested to handle `lm`, `glm`, and `prop.test`, but will likely work with a wider variety of frequentist and Bayesian models as well. It does best when you handle additional information about the variables and/or data generating process, especially for multiple regressions and possible causal inferences. For now you will need an OpenAI API key.

Note that, by default, `aiexplainr` sends your command history up with the summary of the model, so please don't send anything sensitive if you don't trust OpenAI.

Interface inspired by [explainr](https://github.com/hilaryparker/explainr).

## Installation

You can install the development version of aiexplainr like so:

``` r
install.github("mshron/aiexplainr")
```

## Example


``` r
library(aiexplainr)

# set an OpenAI API key
Sys.setenv("OPENAI_API_KEY" = "XXXXXXXX")

# fit a simple linear regression on the `cars` dataset
m1 <- lm(dist~speed, data=cars)
aiexplain(m1, var_desc = "this dataset consists of the speeds (mph) and stopping distances (ft) for cars collected during a test")
```
This is the raw output:

> The linear regression model shows that there is a positive relationship between car speed (in mph) and stopping distance (in ft). For every 1 mph increase in speed, the stopping distance increases by approximately 3.93 ft. The model explains about 65.11% of the variation in stopping distances.

We can analyze a test or model with no side information at all, just based on the summary that the model provides.

```r

m2 <- prop.test(x = c(450, 400), n = c(500, 500))
aiexplain(m2, send_history=FALSE)

```
Output:

> The R output is from a 2-sample test for equality of proportions with continuity correction. The data consists of two groups, with 450 out of 500 in the first group and 400 out of 500 in the second group. The test is comparing the proportions between these two groups.
> 
> The results show that there is a statistically significant difference between the proportions of the two groups, with a p-value of 1.428e-05, which is much smaller than the typical significance level of 0.05. The 95% confidence interval for the difference in proportions ranges from 0.05417387 to 0.14582613. The sample estimates indicate that the proportion in the first group is 0.9, while the proportion in the second group is 0.8.
>
> In conclusion, the test suggests that there is a significant difference between the proportions of the two groups.


In general you will get better results if you explain the variables and/or data generating process, since the LLM will use units and/or reasonable understanding of the phenomena to flesh out the description.

```r
aiexplain(m2, 
          var_desc = "We measured how often toddlers completed a puzzle", 
          datagen = "Data were collected as part of a randomized experiment; group 1 were toddlers who were allowed to nap (the control group) and group 2 were prevented from napping (the treatment group)")
```
Output:

> The data consists of two groups of toddlers: group 1 (control group) who were allowed to nap, and group 2 (treatment group) who were prevented from napping. The study measured how often toddlers completed a puzzle. 
> 
> The results show that 90% of toddlers in group 1 (allowed to nap) completed the puzzle, while 80% of toddlers in group 2 (prevented from napping) completed the puzzle. The test indicates a statistically significant difference between the two groups, with a p-value of 1.428e-05. The 95% confidence interval for the difference in proportions is between 5.4% and 14.6%. This suggests that allowing toddlers to nap may have a positive impact on their ability to complete puzzles.


It also throws an error if you give it something nonsensical. Here we are giving it the first model, but with the toddler description.

```r
aiexplain(m1, 
          var_desc = "We measured how often toddlers completed a puzzle", 
          datagen = "Data were collected as part of a randomized experiment; group 1 were toddlers who were allowed to nap (the control group) and group 2 were prevented from napping (the treatment group)")
```
> The information provided is inconsistent. The R output is related to a linear regression model analyzing the relationship between car speed and stopping distance, while the description of the data collection is about an experiment with toddlers and puzzle completion. Please provide consistent information to proceed with the analysis.
