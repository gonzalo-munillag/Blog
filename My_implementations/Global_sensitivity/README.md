# Global Sensitivity From Scratch

## Goal

The goal of this notebook is to showcase 2 functions, one that implements sensitivity based on the unbounded differential privacy (DP) definition, and another that implements sensitivity based on a bounded definition.
I am not aiming for efficiency but for a deeper understanding of how to implement sensitivity empirically from scratch.

[Notebook](https://github.com/gonzalo-munillag/Blog/blob/main/My_implementations/Global_sensitivity/Global_Sensitivity.ipynb)

## Background

Before continuing there needs to be some clarifications:
In bounded DP, the neighboring dataset is built by changing the records of the dataset (not adding to removing records). E.g. x = {1, 2, 3} (|x|=3) with universe X = {1, 2, 3, 4}, a neighboring dataset in this case would be: x' = {1, 2, 4} (|x'| = 3). They have the same cardinality.
In unbounded DP definition, the neighboring dataset is built by adding ot removing records. E.g. x = {1, 2, 3} (|x| = 3) with universe X = {1, 2, 3, 4}, a neighboring dataset in this case could be: x' = {1, 2} or {1, 3} or {1, 2, 3, 4} (|x|=2 or |x|=2 or |x|=4, but not |x|=3). Their cardinality differs by 1.
The datasets considered are multisets, and their cardinality is the sum of the multiplicities of each value they contain.
The neighboring datasets are also multisets and are considered neighbors if the hamming distance concerning the original dataset is of value k. This parameter is set by the data scientist, but the original definition of DP has a value of k=1 (used for the previous examples).

The hamming distance can be seen as the cardinality of the symmetric difference between 2 datasets. With this in mind, the definition of DP can be written as:

P(M(x) = O) = P(M(x') = O) * exp(epsilon * |x ⊖ x'|)

Where M is a randomized computation, x a dataset, x' its neighbor at hamming distance k = |x ⊖ x'|, and O an output of M given x and x'. 

k is usually 1, to the best of my knowledge, because one aims to protect one individual in the dataset, and by definition, each individual within would therefore be protected. By making the probabilities of obtaining an output O similar between two datasets that differ only in 1 record, one is successfully cloaking the real value of O and therefore not updating fully the knowledge of the adversary, which if done properly, would still be 50/50 between wich dataset was actually the real one. 

Looking at the definition of DP, the higher your k, the more you would increase exp(.), which means that the difference between the probabilities to obtain those outputs will be larger, and thus your privacy would not be equally conserved (although sensitivities increase with k as you can see in the plots).

I have not come across an intuition for having a larger hamming distance (please feel free to [connect](https://www.linkedin.com/in/gonzalo-munilla/) if you have an explanation). Looking at the previous paragraph, it would seem as if having a hamming distance of k=2 would aim to protect pairs of records (individuals), i.e. it accounts for the fact that there are dependencies between records in the dataset that need to be considered as they increase the probability ratio (undesirable). It could make sense if there are some binary relationships between records, e.g. pairs of siblings, or n-ary relationships for k=n, e.g. in a social network. 

I am however far from certain of my hypothesis for the intuition behind a larger hamming distance.

## Contributions of the notebook

1. I programmed a function that calculates the bounded and unbounded sensitivity of a dataset formed by numeric columns- Additionally, it allows you to vary the hamming distance. Its empirical nature will not allow it to scale well, i.e., the function creates all possible neighboring datasets, with k less or more records (for unbounded DP) and with the same amount of records but changing k values (bounded DP). Where k is the hamming distance. The function calculates the query result for each possible neighboring dataset, then calculates all possible L1 norms, and then chooses the maximum. That will be the sensitivity defined in DP.
2. The sensitivity can be calculated for most of the basic queries: mean, median, percentile, sum, var, std, count*.

I tried for different domains, bounded and unbounded sensitivities, different hamming distances. If you are impatient, you can go directly to the [results](#results). 

## Conclusions from results

1. Increasing the hamming distance will increase the sensitivities, it makes sense as the larger the number of elements you can include, the more outliers will be present in the neighboring datasets, increasing the L1 norm. 
2. This increase in sensitivity in turn will increase the noise added. Whether this is helpful or unhelpful (as the hamming distance multiplies the chosen epsilon in the definition of DP), needs further study. On the one hand, having a larger hamming distance will make the probability ratio more distinguishable (undesirable), but at the same time, the randomized mechanisms will contain more noise.
3. Bounded sensitivities seem smaller than unbounded ones. But that is not always the case, you can check the example given in the next [blog post](https://github.com/gonzalo-munillag/Blog/tree/main/My_implementations/Local_sensitivity), where I give a visual example of how sensitivities are calculated.
4. Bounded sensitivities are more taxing to compute than unbounded, but that might be because of how I implemented the functions.
5. Sensitivities, in general, seem to either plateau, have a logarithmic behavior, or linear. However, this is a large leap of faith as the number of samples is very small.

**Note: Unbounded sensitivity can be achieved in 2 ways, either by adding or subtracting records. In this notebook, I computed both at the same time and chose the one that yielded the highest sensitivity. However, I would say that in a real scenario, you could take either and calculate the sensitivity, as both equally protect the privacy of the individuals in the records. However, it is true that for the same privacy guarantees, one might use less noise than the other. This is an object for discussion.**

Note: these conclusions have been drawn from a set of experiments, it sets the ground for hypothesis but to assert the conclusions we would need to prove them theoretically.

## Use case and considerations

I have differentiated between 2 cases:
1. (a) The universe of possible values is based on a dataset, and the size of the released dataset is known before release, i.e. the cardinality of the universe subset. This scenario could be e.g. releasing a study based on some students out of all the students at a school. (Note: the dataset to be released cannot be larger than the dataset used for the universe, only equal or smaller).
2. (b) The universe of possible values is based on a range of values, and the size of the released dataset is known before release. A range is used because the exact values that could potentially be released are not known in advance, thus a range where those values could fall into must be used to perform the sensitivity calculation. This scenario could be e.g. releasing real-time DP results from an IoT device. 
We assume that the size of the released dataset is known, i.e. we know there are n amount of records being queried or from which a synopsis (statistical summary) will be made. This is safe to assume as the number of users or IoT devices in an application can be designed to be known*.
For simplicity, from now on, I will call the datasets D_universe_a and _b, D_release_a and _b, and D_neighbor for (a) and (b).

Note that this is somewhat different from the online (on) (or interactive) and the offline (off) (or non-interactive) definition that [C. Dwork](https://www.cis.upenn.edu/~aaroth/Papers/privacybook.pdf) introduces in her work. These deal with not knowing or knowing the queries beforehand, respectively. But, we could have the case (a) and case (b) in both (on) or (off):
1. Scenario (a) + (on): API that allows external entities to query in a DP manner a subset of the school dataset you host internally (or its entirety).
2. Scenario (a) + (off): Release externally a DP synopsis (statistical summary) of a subset of the school dataset you host internally (or its entirety).
3. Scenario (b) + (on): API that allows external entities to query in a DP manner a dataset updated in real-time by IoT devices hosted internally or decentrally.
4. Scenario (b) + (off): Release externally a DP synopsis of a dataset updated in real-time by IoT devices hosted internally or decentrally.

For this notebook, we will consider Scenario (a) + (off) and (b) + (off).

Also note that (a) and (b) is also somewhat different to (i) **local DP (LDP)**. LDP is applied at the device level on individual data points before any third party aggregates all data points from all devices, usually randomized response is the DP mechanism of choice. They are also different to (ii) **global DP (GDP)**. GDP is applied when a trusted third party gathers all the data and applies a DP mechanism on the aggregate and not at a record-level. GDP is not as restrictive as LDP in terms of allowed DP mechanisms. This notebook is focused on GDP. So we have (a) + (off) + (GDP) and (b) + (off) + (GDP). 

## Mean questions for clarification: 
- How can (b) and (GDP) go together? The third-party can host a server to process real-time data. 
- Then, why does not the third party aggregate this real-time data and do (a) instead of (b)? It could, but because your dataset is ever-growing, you would need to compute sensitivities every time your dataset would change, which is in real-time, that can be computationally inefficient. 
- But still, you could do (a), right? You could, but you would have to release data over a defined period and release a synopsis aggregating these data. Thus, your service would not be as close to real-time anymore as it would be with (b). But definitively, it is a question to further investigate.
- So what is the major benefit of (b)? You do not need to re-compute your sensitivities, the drawback is that if your domain of possible values is very large then your noise will be larger. In (a) your universe might not contain such wide possible ranges, so it benefits your accuracy. But you can also fine-tune your range in D_universe_b based on an older sample of D_release_b. **But definitively you would like to calculate your sensitivities in case of (b) with an upper bound found theoretically, as finding it empirically is computationally expensive**
- Mmm, and what if you do not know the full domain of your universe? That is indeed a good question. Well, then you will have to do some clipping to not get any surprises. E.g., if you defined your universe like D_universe_b = {'Age': [1, 2, ..., 99, 100]}, but you get a value in real-time like [122](https://en.wikipedia.org/wiki/List_of_the_verified_oldest_people), then you should do top-coding, 122->100, so you can include its value. Outliers and DP do not go well. You can protect them, but the cost would be too high (higher noise), and why would you do that? DP allows you to perform statistical queries, the mean or the sum would not be representative of the population if there are outliers in it. DP is used to learn from a population, not from outliers, if you would like to learn about outliers, then DP is not for you. 

### Further clarification
The main difference in this notebook between scenario a and b (aside from the one mentioned), is programmatic: How you define the universe to input into the functions. The functions I created (for the sensitivities in unbounded and bounded DP) serve both scenarios. But in scenario b, aside from the fact that you have only a range of values, to calculate the sensitivity, you have to make as many replicates of each value of the universe as the size of the released dataset. Why? Because if you define your range like e.g. D_universe_b = {'Age': [1, 2, ..., 99, 100]} and with a |D_release| = 4, you could on real-time get a D_release_b={'Age':[100,100,100,100]} or another like D_release_b={'Age':[35, 35, 35, 35]}.

Something to also note is that the functions that calculate the sensitivities only need a universe and the size of the released dataset (together with the hamming distance). They do not need the actual release dataset, which could be a possibility.

### Limitations:
1. The functions to calculate sensitivity do not scale well in terms of the size of your universe
2. *****The count query sensitivity should be 1 for unbounded and 2 for bounded DP. The former is clear because you just add or remove one record, increasing or decreasing the total count of the record by one. However, if you have bounded sensitivity, the change of one record might lead to the decrease of the count of one record and the increase of the count of another, yielding a total difference of 2. These 2 cases are not accounted for, we solely count the number of elements in the array, which leads to a sensitivity of 1 in unbounded and of 0 inbounded. To empirically prove the fact that for bounded you have a sensitivity of 2, there needs to be more work done on how the query results are handled, which is a lot of extra workload for obtaining a solution that is already well known.**

***** If the number of users/IoT devices is desired to be protected, then one can take a large sample of records, but not all the records, and the cardinality considered would be the number of the sampled records. Thus an attacker would not know the actual number of users/IoT devices.

<a name="results"></a>
# Results

**(Ignore the decimals on the x-axis, hamming distances are integers)**

![unbounded_a](Images/unbounded_a.png)
![bounded_a](Images/bounded_a.png)

![unbounded_b](Images/unbounded_b.png)
![bounded_b](Images/bounded_b.png)
