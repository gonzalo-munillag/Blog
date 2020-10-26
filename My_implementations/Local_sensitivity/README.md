# Local Sensitivity From Scratch

## Goal

The goal of this notebook is to implement the calculation of local sensitvity form scratch. 
It is benchmarked against the results of the global sensitivity from my previos [blog post](https://github.com/gonzalo-munillag/Blog/blob/main/My_implementations/Global_sensitivity/Global_Sensitivity.ipynb). 

[Notebook](https://github.com/gonzalo-munillag/Blog/blob/main/My_implementations/Local_sensitivity/Local_Sensitivity.ipynb)

## Background

Local sensitivity differs from global sensitivity in that it considers only the dataset to be released, and not all the possible release datasets. 
This means that you only calculate the neighbors of the release dataset, and not of all possible datasets. 
And it is only within these neighbors and their corresponding release dataset that you find the maximum norm. 
Global sensitivity is therefore an upper bound of local sensitivity. 

**Note: Unbounded sensitivity can be achieved in 2 ways, either by adding or subtracting records. In this notebook I computed both at the same time and chose the one that yielded the highest sensitivity. However, I would say that in a real scenario, you could take either and calculate the sensitivity, as both equally protect the privacy of the individuals in the records. However, it is true that for the same privacy guarantees, one might use less noise than the other. This is an object for discussion.**


### Contributions of notebook


1. Two functions to calculate the local sensitivity of a dataset empirically.
2. Comparisons between local and global sensitivity results.
3. A visualization of sensitivities for a median query, with the goal to show how to calclate sensitivities locally and how bounded and unbounded sensitivity differ visually

### Mean questions for clarification
- If local sensitivity would imply less noise due to its smaller value, then why do we not always use local sensitvity?  If for each dataset you would calculate its particular loca sensitvity, then adversary could also take that into consideration when plotting noise distributions of the different possible dataset release combinations. These distributions would have a lower std, and thus, once the adversary gets a query DP result, it would be easier for him/her to discard possible release datasets (A visual representation of this process carried out by an attacker is in the [paper](https://git.gnunet.org/bibliography.git/plain/docs/Choosing-%CE%B5-2011Lee.pdf) I implemented 2 blog posts ago, depicted in Figs. 1 and 3). That is why some researchers invented smooth bounds for local sensitivities, but that is something I will cover in future blog posts.

### Comments

This is a 3rd blog post of a series of posts revolving around [sensitivities](https://github.com/gonzalo-munillag/Blog/tree/main/My_implementations/Global_sensitivity) and [epsilon](https://github.com/gonzalo-munillag/Blog/tree/main/Extant_Papers_Implementations/A_method_to_choose_epsilon)
I invite you to have a look at them as well :)

**TIP**: The best way to understand this notebook better is to open my previous [blog post](https://github.com/gonzalo-munillag/Blog/blob/main/My_implementations/Global_sensitivity/Global_Sensitivity.ipynb) and go the visualizations of scenario (a), and to cell 25 for unbounded and cell 33 for unbounded sensitvity in order to compare the raw data.

### Results

You can see the comparisons of the plots between local and global sensitivities. (Ignore the decimals on the x axis, hamming distances are integers)

For the visual representation, we have chosen:
- Universe of possible values: X = {1, 2, 3, 10, 11}
- Release dataset size (cardinality) = 3
- Hamming distance = 1
- x are all the possible value combinations from X
- x' are all the possible neighbors for each x
- Neighbor's cardinality difference is set to the hamming distance of 1, | |x| - |x'| | = 1
- The L1 norm is calculated with the Query(Median) result of the possible release dataset (on the 2nd column) and with each of the Query(Median) results of each of the types of neighboring datasets.
- I select the first maximum for each group of L1 norms.

In this case, unlike in the previous blog post(), the bounded sensitivity of value 8 is higher that the unbounded ones of values 4.5 and 4, for subtracting and adding a record respectively. 

Notice the local sensitivities are calculated on the horizontal axis, there is one per possible release dataset (first column). The global sensitivity is calculated in the vertical axis, selecting the maximum value out of all the L1 norms, i.e. slecting the maximum out of all local sensitivities.

General form of L1 unbounded sensitivity:

![unbounded_sensitivity_formula](Images/unbounded_sensitivity_formula.png)

General form of L1 bounded sensitivity:

![bounded_sensitivity_formula](Images/bounded_sensitivity_formula.png)

![sensitivities_median_manual_calculations](Images/sensitivities_median_manual_calculations.png)

**Here come the figures!**

**(Ignore the decimals on the x axis, hamming distances are integers)**

#### UNBOUNDED - Local Sensitivity

![unbounded_sensitivity_plot](Images/unbounded_sensitivity_plot.png)

It is interesting to see that the sensitivity for variance declines and at least for the sum the local sensitivity seems to be equal to the global sensitivity. 
The rest have lower values. This means that this particular dataset is the one with the maximum sensitivity for sum. 

##### Vs.

#### UNBOUNDED - Global Sensitivity

![unbounded_a](Images/unbounded_a.png)

#### BOUNDED - Local Sensitivity

![bounded_sensitivity_plot](Images/bounded_sensitivity_plot.png)

##### Vs.

#### BOUNDED - Global Sensitivity

![bounded_a](Images/bounded_a.png)

At a first glance, the bounded local and global sensitivities seem equal, but if you pay close attention, for some queries they are not.
