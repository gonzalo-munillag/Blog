# A conflicting definition of DP

A colleague of mine pointed me to a definition of differential privacy (DP), which was included in a slide deck for a seminar at TU Munich. He shared it because he felt there was something off about it. This post is the result of this discussion.

I aim to dissect the meaning of this definition and explain why I do not completely agree.

The definition of our bullseye:

"Differential privacy aims to provide means to **maximize** the accuracy of queries from statistical databases while **minimizing** the chances of identifying its records". 
First of all, that is not a definition for DP, that is one of the byproducts for which DP is useful, and partly for what DP was created. They are describing a goal, not a definition. Perhaps the authors intended it as such, then *hey, fair enough*. But even so, as my colleague correctly pointed out, there is something off using "maximizing" and "minimizing" in the same sentence.


## About the definition of DP:

Definitions from the people who invented DP (1, 2), and an awesome researcher (3):

(1)
" It differs from most previous definitions in that it does not attempt to guarantee the prevention of data disclosures, privacy violations, or other bad events; instead, it guarantees that participation in the data set is not their cause.
The definition of differential privacy requires that a randomized computation yield nearly identical distributions over outcomes when executed on nearly identical input data sets. " - [Pg. 3, Privacy integrated Queries](https://www.microsoft.com/en-us/research/wp-content/uploads/2009/06/sigmod115-mcsherry.pdf)

(2)
" An Economic View. Differential privacy promises to protect individuals from any additional harm that they might face due to their data being in the private database x that they would not have faced had their data not been part of x." - [Pg. 20, Algorithmic foundations](https://www.cis.upenn.edu/~aaroth/Papers/privacybook.pdf)

(3)
"For an individual whose data is represented by a record in **I**, differential privacy offers an appealing guarantee. It says that including this individual’s record cannot significantly affect the output: it can only make some outputs slightly more (or less) likely – where “slightly” is defined as at most a factor of exp(epsilon). If an adversary infers something about the individual based on the output, then the same inference would also be likely to occur even if the individual’s data had been removed from the database before running the algorithm."

Standing on the shoulders of giants, I define DP as follows: DP is a mathematically guarantee that any individual in a dataset is indistinguishable from others to an extent bounded by a factor of exp(epsilon).

If the upper bound is small, the more indistinguishable someone is, and vice-versa. This indistinguishability could be seen as the posterior probability of an adversary, i.e. the adversary's guess about the individual being someone specific, e.g. Peter, after seeing the DP query result is probabilistic; no matter how you choose epsilon, the adversary will have not complete certainty. Although this is not always true in practicality when epsilon tends to infinity, then the indistinguishability tends to 0, i.e. the posterior probability of someone in the dataset being Peter tends to 1. 

Put simply, my understanding of the goal/aim of DP is to protect the privacy of an individual in a dataset. But how you define the "aim" is subjective, someone could also say that DP aims to help in this trade-off between privacy and utility, like in the definition that triggered this post. The reality is that DP does not aim, it is a tool that you aim to do privacy stuff. So all aims that align with the definitions from these experts are valid. So the takeaway here, if one wants to be proper, is not to confuse definitions with aims.
 

## Why having "maximizing" and "minimizing" in the same sentence is wrong?

Coincidentally, what DP does is to help practitioners to provide a number for the trade-off between privacy and utility, namely epsilon and e.g. accuracy, or selectivity, or recall, or mean square error, etc.,m respectively. So it is easy to set an epsilon and see how your e.g. accuracy is affected. Your epsilon is proportional to your utility (any utility metric actually), so you could in theory just use epsilon. The problem is that epsilon is not intuitive. While you know that epsilon is proportional to utility and inversely proportional to privacy, the practitioner does not know to which extent epsilon will affect the utility metric. 

So that is why you could perform a loop:  
1. Set acceptance criteria for your utility metric e.g. accuracy.  
2. while (utility != acceptance criteria):  
3. Apply DP with an epsilon.  
4. Apply your model and measure accuracy and benchmark it against your acceptance criteria.
5. If it does not check, go back to line 3. Lower the epsilon and check accuracy until it checks.  
6. If it checks, then end OR go back to line 3 if you think you do not need so much utility, and therefore you could do with more privacy.  

You could use a binary search as the tool to find the optimal solution, as it was suggested in this [extant paper](https://git.gnunet.org/bibliography.git/plain/docs/Choosing-%CE%B5-2011Lee.pdf) I took the time to [implement](https://github.com/gonzalo-munillag/Blog/tree/main/Extant_Papers_Implementations/A_method_to_choose_epsilon).

This loop that I described is an optimization problem, you want to maximize utility (a target function), and you try epsilons (systematically selecting inputs) to see how close you get to that accuracy (compute the function, the whole process in this case) and stop until you reach it. We thus would find the best solution. 

Going back to: "Differential privacy aims to provide means to **maximize** the accuracy of queries from statistical databases while **minimizing** the chances of identifying its records". It is not necessarily describing an optimization problem, but if it does, then my colleague was right: you have one function to maximize and the other function you would like to minimize is its inverse, so it does not work; one can not maximize the target variable while trying to minimize the variable of which the former is dependent on.

To avoid confusion, I would have written: "Differential privacy aims to provide means to maximize the accuracy of queries from statistical databases while **fitting an upper bound** to the chances of identifying its records”. Why bounding? Well, you choose epsilons until you found the optimal one for the given utility acceptance criteria. And what does the final epsilon do? It bounds the probability of an adversary identifying an entity in the dataset. You are **fitting** epsilon to your problem, using "minimizing" in my humble opinion, is not correct. 

This is what I think they tried to convey with their definition: They aim to find the maximum epsilon (an upper bound, this equals to the part of “... while minimizing the chances ...”) for which they obtain their minimum utility (a lower bound = acceptance criteria = “... maximize the accuracy ...”).  A bigger epsilon is not okay, but a smaller epsilon is okay, but you would get less utility.  A smaller utility is not okay, a higher utility is okay, but you would leak more privacy. So the trick is to set your utility to the bare minimum of what you need and fit your epsilon to that value. And this is from where I think the confusion with the given definition comes, there are a lot of ways to describe this process that seem true, but technically they are not. However, it depends on what the writer has in his/her head that is being maximized or minimized.  
Personally, I would not mix those two words in the same sentence, as they make the sentence paradoxical.


## My takeaways

 1. We have to be mindful of the distinction between aim and definition.
 2. My definition of DP: DP is a mathematically guarantee that any individual in a dataset is indistinguishable from others to an extent bounded by a factor of exp(epsilon).
 3. How I would re-write their goal: Differential privacy aims to provide means to maximize the accuracy of queries from statistical databases while fitting an upper bound to the chances of identifying its records.
 3. You can see finding epsilon as an optimization problem that tries to maximize utility, OR rather (in my point of view) you can see it as fitting epsilon to a given utility acceptance criteria.


However, I could be wrong for all I know; this is the reason why I write this blog, to become smarter together with you!  
What is your opinion?
