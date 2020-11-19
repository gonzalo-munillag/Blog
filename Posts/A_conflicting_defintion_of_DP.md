"Differential privacy aims to provide means to maximize the accuracy of queries from statistical databases while minimizing the chances of identifying its records" - That is not a definition for DP, that is one of the byproducts for which DP is useful for, and partly for what DP was created. They are describing an aim, not a definition.


 

About the definition:

DP is mathematically guaranteeing that any individual in a dataset is indistinguishable from others to an extent bounded by a parameter. (parameter = epsilon) If the bound is small, the more indistinguishable someone is, and vice-versa. This indistinguishability is just a posterior probability of an adversary. The adversary's guess about the individual being e.g. Florian is probabilistic, no matter how you choose epsilon, the adversary will have not complete certainty. This is not always true though when epsilon tends to infinity, then the indistinguishability tends to 0, i.e. in maths terms: the posterior probability of someone in the dataset being Florian tends to 100%. 

My opinion is that what DP aims to do is to protect the privacy of an individual in a dataset. But this "aims" is very subjective, someone could see that DP aims to help in this trade-off (like the sentence you shared). The reality is that DP does not aim, it is just a tool that you take and then you aim to do stuff with it. So all aims that align with the definition I provided are valid. (that definition is mine, a distillation of what I know, not from the book, so better to cross-check that). So we stay strong and let us not confuse the definition of DP with its aim.


 

About the optimization dilemma and the "aim" you shared:

Coincidentally, what DP does is to help practitioners to provide a number for the trade-off between privacy and utility, namely epsilon and e.g. accuracy, or selectivity, or recall, or mean square error, etc. So it is easy to set an epsilon and see how your e.g. accuracy is affected. Your epsilon is proportional to your utility (any utility metric actually), so you could in theory just use epsilon. The problem is that epsilon is not intuitive. While you know that epsilon is proportional to utility and inversely proportional to privacy, the practitioner does not know to which extent epsilon will affect the utility metric. 

So that is why you could do a loop: (0) Set acceptance criteria for your utility metric e.g. accuracy  (1) apply DP with an epsilon, (2) apply your model and measure accuracy and benchmark it against your acceptance criteria, (3) (3.1) not good enough go back to (1), lower epsilon and check accuracy until good. (3.2.) if it is good, then finish or go back to (1) if you think there is enough utility and you could decrease it and trade it for privacy off. You could use a binary search as the tool to find the optimal solution.

This loop that I described is an optimization problem, you want to maximize utility (a target function), and you try epsilons (systematically selecting inputs) to see how close you get to that accuracy (compute the function, the whole process in this case) and stop until you reach it. We thus found the best solution. 

Going back to: "Differential privacy aims to provide means to maximize the accuracy of queries from statistical databases while minimizing the chances of identifying its records". It is not necessarily describing an optimization problem, but if it does, then Sascha is right. You have one function to maximize and the other function you would like to minimize is its inverse, so it does not work. 

To avoid confusion, I would have written: "Differential privacy aims to provide means to maximize the accuracy of queries from statistical databases while tightly fitting an upper bound to the chances of identifying its records”. Why bounding? Well, you choose epsilons until you found the optimal one for the given utility acceptance criteria. And what does the final epsilon do? It bounds the probability of an adversary identifying an entity in the dataset. You are fitting epsilon to your problem. 

And what did they try to say with their “aim”? They try to find the maximum epsilon (an upper bound, this equals to the part of “ while minimizing the chances…”) for which they obtained their minimum utility (a lower bound of utility = acceptance criteria = “.. maximize the accuracy…”).  A bigger epsilon is not okay, but a smaller epsilon is okay.  A smaller utility is not okay, a higher utility is okay, but you would leak more privacy. So the trick is to set your utility to the bare minimum of what you need and optimize your epsilon to that value. And this is I think where the confusion with the “aim” comes from, there are a lot of ways to describe this process that seem true, but technically they are not depending on what you have in your head being maximized or minimized. I would nor mix those two words in the same sentence though, I agree with your old Prof.



My takeaways:

 1. Distinction between aim and definition

 2. You can have an optimization problem maximising utility OR rather you can see it as fitting epsilon to a given utility acceptance criteria.