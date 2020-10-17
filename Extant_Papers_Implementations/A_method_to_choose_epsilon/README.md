# Choosing Epsilon

The goal of this notebook is to implement the following paper from 2011 with around 20 citations: [link to pdf](https://git.gnunet.org/bibliography.git/plain/docs/Choosing-%CE%B5-2011Lee.pdf), [link to Springer Link](https://link.springer.com/chapter/10.1007/978-3-642-24861-0_22)

This paper states that even though Differential Privacy (DP) protects any individual in a dataset by cloaking with noise the most extreme query answers possible between 2 neighboring datasets, due to the finite amount of dataset possibilities and the worst case adversary model (almost perfect background knowledge and infinite computation power), some distributions of the real dataset behind the DP query results are more likely than others, and therefore this needs to be taken into consideration when calculating epsilon. The authors used bounded and unbounded sensitivity (although back then apparently were not referred to them as such) to find a tight bound for epislon with binary search.

My humble opininon is that the paper is succint, elegant and it has the ability to take your understandiung of DP further. I would like to thank the authors **Jaewoo Lee** and **Chris Clifton** for these two days I spent implementing :) and I imnvite everyone to have a look at the paper and check the code if you want to understand it better.

Contributions/realisations of this notebook:
	
	- I coded a function that calculates the bounded and unbounded sensitivity of a dataset formed by numeric columns. Probably it will not scale well (as it must calculate all the possible neighboring datasets given a universe of values), but you can validate any formula that claims to calculate the sensitivity for a specific query. However, how to code the algorithm was not explained on the paper. The function also allows you to vary the hamming distance and see how that affects the sensitivity and therefore the noise (It increases, but that is known as the definition for DP goes: P(M(x) = O) <= P(M(x') = O) * exp(epsilon) * hamming_distance).
  - i.e.: This function to empirically calculate the sensitivity creates all possible neighbouring datasets, with k less or more records (for unbounded DP) and with the same amount of records but changing k values (bounded DP). Where k is the hamming distance. The function calculates the query result for each possible neighbouring dataset, then calculates all possible L1 norms, and then chooses the max.
	- I found no mistakes in the paper, only a typo of a number when substituting values in a formula (The numertaor should be 0.3062 and not 0.3602 in page 333 (9 of the PDF)). 
  - I coded the formulas for uniform prior, posterior, upper and tighter bound of the posterior, for a given dataset and query type.
	- I coded the binary search explained in the paper to find the correct value of epsilon (given a disclosure risk), for any query type.
	- The authors did not point out they used bounded and unbounded DP, I guess back then it was not very stablished. But now in retrospective, it is so cool to see how the different basis for the DP definition come together to find an optimal epsilon. 
  - With this code, you can easily play by using larger or different datasets than the one used in the paper. I used that exact one to replicate the results they had. 
  - This notebook implements more queries, beyond the Mean and the Median used for explanations. Feel free to try them!
  - An idea I just had, however it needs further investigation: I think that the hamming distance (if >1) could be used to protect groups of individuals if they are dependent, e.g. if there is a dataset with sibling couples (hamming distance 2), or if there are friends in the dataset e.g. in a social network, all their data dependencies could be protected with a hamming distance equal to the number of their connections, choosing the maximum, i.e. the most connected person's number of connections.
  
  Some concepts before we start:

- When I talk about bounded sensitivity, I refer to the sensitivity that comes from a bounded DP definition, i.e. the neighboring dataset is built by changing the records of the dataset (not adding ot removing records). E.g. x = {1, 2, 3} with universe X = {1, 2, 3, 4}, a neighboring dataset in this case would be: x' = {1, 2, 4}
-  When I talk about unbounded sensitivity, I refer to the sensitivity that comes from an unbounded DP definition, i.e. the neighboring dataset is built by adding ot removing records) E.g. x = {1, 2, 3} with universe X = {1, 2, 3, 4}, a neighboring dataset in this case could be: x' = {1, 2} or {1, 3} or {1, 2, 3, 4}
- The prior is the priro knowledge of an adversary, i.e. his/her best guess about which dataset is probably the real one. The paper and this notebook assumes a uniform prior.
- The posterior is the updated knowledge of the adversary, i.e. once he/she has seen the query results,  the posterior maps a probability to a possible real dataset. The higher it is, the more confident will the adversary be about a dataset being the real one.

