# Association rules - arules package R
library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats','arules', 'arulesViz')

#data("Groceries")
#head(Groceries)

# Before converting the dataframe into a transactional dataset, we must ensure that we convert each column into a factor or a logical to ensure that the column takes values only from a fixed set.

#data("AdultUCI")
# Each transaction of a transactional dataset contains the list of items involved in that transaction. 
# When we convert the dataframe into a transactional dataset, each row of this dataframe will become a transaction. 
# Each column will become an item. But if the value of a column is numeric, it cannot be used as the column can take infinite values. 

#AdultUCI <- AdultUCI %>% 
#  mutate_if(is.numeric, as.factor)
#str(AdultUCI)

#transactional_data <- as(AdultUCI, "transactions")
#inspect(head(Groceries, 1))

# https://www.datasciencecentral.com/profiles/blogs/data-mining-association-rules-in-r-diapers-and-beer
# https://www.youtube.com/watch?v=eOOhn9CX2qU&ab_channel=LanderAnalytics

# unsupervised learning

# Analyses which defines rules ####

# Steps/item sets
# {X} and {Y}

# Support is a measure of the frequency of both steps/item sets occurring together. It is the proportion of transactions which contains the itemset

# Confidence - conditional probability that the rule is found to be true. It is the proportion of transactions containing X that also contain Y. Thus confidence can be interpreted as an estimate of the conditional probability of finding the RHS of the rule in transactions under the condition that these transactions also contain the LHS.

# Lift - measure of dependent or correlated. This is the ratio of the observed support to that expected if X and Y were independent.

# If the rule had a lift of 1, it would imply that the probability of occurrence of the antecedent and that of the consequent are independent of each other. When two events are independent of each other, no rule can be drawn involving those two events. If the lift is < 1, that lets us know the items are substitute to each other. This means that presence of one item has negative effect on presence of other item and vice versa.

# If the lift is > 1, that lets us know the degree to which those two occurrences are dependent on one another, and makes those rules potentially useful for predicting the consequent in future data sets.

# The value of lift is that it considers both the support of the rule and the overall data set.

# Apriori algorithm uses a breadth-first search strategy to count the support of itemsets and uses a candidate generation function which exploits the downward closure property of support.

# Build association mining rules with titanic dataset pinning an outcome variable ####

# https://www.daveondata.com/blog/titanic-market-basket-analysis-with-r/

titanic_df <- read_csv('train.csv') %>% 
  bind_rows(read_csv('test.csv')) %>% 
  select(!Survived)

# This needs to be logical values for each field (male yes/no, female yes/no), rather than sex male/female
titanic.features <- titanic_df %>%
  mutate(FirstClass = (Pclass == 1),
         SecondClass = (Pclass == 2),
         ThirdClass = (Pclass == 3),
         Female = (Sex == "female"),
         AgeMissing = is.na(Age),
         Child = (!is.na(Age) & Age < 18),
         Adult = (!is.na(Age) & Age > 17 & Age < 55),
         Elderly = (!is.na(Age) & Age >= 55))

# Groups of passengers share the same ticket numbers. We can use this information to create some more binary features based on the characteristics of Ticket groups.

titanic.ticket.groups <- titanic_df %>%
  group_by(Ticket) %>%
  summarize(IsSolo = (n() == 1), # Is there just one person on the ticket 
            IsCouple = (n() == 2), # Are there two people with the same ticket number
            IsTriplet = (n() == 3), # Are there three people with the same ticket number
            IsGroup = (n() > 3), # Are there more than three people in the group 
            HasChild = ifelse(sum(!is.na(Age)) > 0, min(Age, na.rm = TRUE) < 18, FALSE), # Is there at least one child in the group
            HasElderly = ifelse(sum(!is.na(Age)) > 0, max(Age, na.rm = TRUE) >= 55, FALSE), # Is there at least one older person in the group
            NoAges = sum(!is.na(Age)) == 0) # Do we have no age info for anyone in the group

# Join the ticket groups to the binary dataset we created and keep passenger ID so we can add survival outcome
titanic.binary <- titanic.features %>% 
  left_join(titanic.ticket.groups, by = 'Ticket') %>% 
  select(PassengerId, FirstClass, SecondClass, ThirdClass, Female, AgeMissing, Child, Adult, Elderly, IsSolo, IsCouple, IsTriplet, IsGroup, HasChild, HasElderly, NoAges)

# we only had survival outcome from the train dataset but we used the test dataset to add more info about the ticket groups
titanic.binary <- titanic.binary %>% 
  filter(PassengerId %in% read_csv('train.csv')$PassengerId) %>% 
  left_join(read_csv('train.csv')[c('PassengerId', 'Survived')], by = 'PassengerId') %>% 
  mutate(Survived = (Survived == 1)) %>% 
  select(-PassengerId)

# Here we have an outcome (survival)
# Transform the dataset into a transactions object for the arules package
titanic.trans <- as(titanic.binary, "transactions")

# This line of code performs the work of the MBA:
#    1 - Specifies a minimum support of 0.05 and confidence of 0.1
#    2 - Speciis a maxium of two "items"
#    3 - "Pins" the Survived "item" as the right-hand side (rhs)
#
# Net result will be all the non-Survived items on the lhs

rules.one.feature <- apriori(data = titanic.trans, 
                            parameter = list(supp = 0.05, # return rules that occur in at least 5% of transactions
                                             conf = 0.1, # return rules where at least 10% had the RHS outcome
                                             minlen = 2, 
                                             maxlen = 2), 
                            appearance = list(default ="lhs", rhs = "Survived"), 
                            control = list(verbose = FALSE))

rules.one.lift <- sort (rules.one.feature, by = "lift", 
                        decreasing = TRUE)

inspect(rules.one.lift) %>% 
  view()

# You can see from this that Child has a .068 Support and .54 confidence and a lift value of 1.4.

# Support is how often Child appears in the dataset
titanic.binary %>% 
  group_by(Child, Survived) %>% 
  summarise(Transactions = n()) %>% 
  ungroup() %>% 
  mutate(Proportion = paste0(round(Transactions / sum(Transactions) * 100,1), '%'))

# You can see that Child = TRUE and Survived = TRUE occurs in 61 or 6.8%

titanic.binary %>% 
  filter(Child == TRUE) %>% 
  group_by(Survived) %>% 
  summarise(Transactions = n()) %>% 
  ungroup() %>% 
  mutate(Proportion = paste0(round(Transactions / sum(Transactions) * 100,1), '%'))

# Now among those transactions containing the LHS set (Child = TRUE), how many also have the RHS set (Survived = TRUE). This is 54

# The lift metric tells you how many more times likely is the right-hand side to happen, assuming the left-hand side, compared to all transactions. In this case, Survived is 1.4 times more likely.

# More complex rules that account for combinations of item sets 

rules.three.features <- apriori(data = titanic.trans, 
                                parameter = list(supp = 0.05, 
                                                 conf = 0.1, 
                                                 minlen = 2, 
                                                 maxlen = 4), # This time we have included max length of four, that is up to three items in the LHS set plus the Survived item in the RHS set 
                                appearance = list(default ="lhs", 
                                                  rhs = "Survived"), 
                                control = list(verbose = FALSE))

rules.three.lift <- sort(rules.three.features, by = "lift", decreasing = TRUE)

inspect(head(rules.three.lift, n = 10))

# Does adding greater number of items in sets make a difference?
rules.five.features <- apriori(data = titanic.trans, 
                                parameter = list(supp = 0.05, 
                                                 conf = 0.1, 
                                                 minlen = 2, 
                                                 maxlen = 6), # This time we have included max length of six, that is up to five items in the LHS set plus the Survived item in the RHS set 
                                appearance = list(default ="lhs", 
                                                  rhs = "Survived"), 
                                control = list(verbose = FALSE))

rules.five.lift <- sort(rules.three.features, by = "lift", decreasing = TRUE)

inspect(head(rules.five.lift, n = 200)) %>% 
  view()

# Take constraint off
rules.features <- apriori(data = titanic.trans, 
                               parameter = list(supp = 0.05, 
                                                conf = 0.1, 
                                                minlen = 2, 
                                                maxlen = 6), # This time we have included max length of six, that is up to five items in the LHS set plus the Survived item in the RHS set 
                               control = list(verbose = FALSE))

rules.lift <- sort(rules.features, by = "lift", decreasing = TRUE)

inspect(head(rules.lift, n = 10))
