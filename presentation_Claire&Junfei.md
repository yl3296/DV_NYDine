---
title: "Final Project Presentation - topic modeling with LDA and visualization"
author: "Yang Liu(yl3296)" "Junfei Shen(js4567)"
date: "Thursday, April 23, 2015"
output: html_document
layout: post
description: Final Project
tags: topic modeling, wordcloud, shiny, yelp
---


##1. Introduction
--------
We focus on customer reviews for restaurants， applying topic modeling on reviews data.
**Topic model:**
* Unsupervised machine learning based on text data
* One of the most useful algorithm__LDA

##2. Prepare data
**Our datasets:**
* yelp_academic_dataset_business.json
* yelp_academic_dataset_reviews.json
** Prepare data:
* Convert json to csv:

```
#Convert a json string to a flat python dictionary which can be passed into Pandas.

import json
import pandas as pd
from glob import glob
 
def convert(x):

    ob = json.loads(x)
    for k, v in ob.items():
        if isinstance(v, list):
            ob[k] = ','.join(v)
        elif isinstance(v, dict):
            for kk, vv in v.items():
                ob['%s_%s' % (k, kk)] = vv
            del ob[k]
    return ob
 
for json_filename in glob('*.json'):
    csv_filename = '%s.csv' % json_filename[:-5]
    print 'Converting %s to %s' % (json_filename, csv_filename)
    df = pd.DataFrame([convert(line) for line in file(json_filename)])
    df.to_csv(csv_filename, encoding='utf-8', index=False)

```
* Read in R and data preprocessing:

```
# Prepare packages in R for LDA
install.packages("tm")
install.packages("topicmodels")
install.packages("ggplot2")
# Read csv in R and filter reviews for restaurants
data_bus <- read.csv("business.csv", stringsAsFactors=FALSE)

# Find indices of business with "restaurant" as category
loc <- grep("R,e,s,t,a,u", data_bus$categories, perl=TRUE, value=FALSE)
data_bus_subset <- data_bus[loc,]

# Select only restaurant reviews. There are 990627 reviews.
data_review_restaurant <- subset(data_review, data_review$business_id %in% data_bus_subset$business_id &nchar(toString(text)) > 100)
cat("Number of restaurant reviews: "); print(dim(data_review_restaurant))
print(dim(data_review_restaurant)[1]*9/10)

# Separate into training (90%) and testing set (10%)
index <- sample(nrow(data_review_restaurant), nrow(data_review_restaurant)*.9)
data_review_restaurant.train <- data_review_restaurant[index, ]
data_review_restaurant.test <- data_review_restaurant[-index, ]
cat("Training set: "); print(dim(data_review_restaurant.train))
cat("Testing set: "); print(dim(data_review_restaurant.test))
* Key code in getting top 30 topics.
  Each topic has 10 key words. 
  Words in each topic are ordered by decreasing order by frequency.
  
```

##3. LDA
**Split the dataset into training data and testing data, get the top 30 topic:**

import os
import re
from gensim import corpora, models, similarities
import pylab as pl

data_review_restaurant_train = %Rget data_review_restaurant.train_1
data_review_restaurant_test = %Rget data_review_restaurant.test

stoplist = set('came way dad yes try oh phoenix one two three four th alot well wasn went now doesn know want give take said lo r w co st v o b c g p bf ok k l n x f didn m nice restaurant back food good great place don always a about above after again against all am and any are at as be because been before being below between both but by can cant cannot could couldnt do did does down each for from further had have here how if me no nor not our of the and to too i is in into on there then them themselves this it he she her him you so some that was with would more or they will do has which an embedded quote its embed dont out who whom why where when his very other only while their http www up com than my your also most mostly never next what much one such many us were we over own often should shall same that those under until when won d re s t ll ve im these just isnt ive theres go going get got however made meanwhile please perhaps see seem seems thru even doesnt hes wouldnt thats youre wasnt youll really got like make makes think around through didnt doing may might maybe wont u arent werent ill e'.split())

# LDA, k number of topics
k = 30

# If LDA model doesn't exist already...
if not os.path.isfile('LDA/lda_model'):
    # Do everything
    print "Generating LDA model..."
    if not os.path.exists('LDA'):
        os.mkdir('LDA')
    corpus = []
    for review in data_review_restaurant_train:
        # Only care about documents of certain length
        if (len(review) > 100):
            # Remove punctuations
            review = re.sub(r'[^a-zA-Z]', ' ', review)
            # To lowercase
            review = review.lower()
            # Remove stop words
            texts = [word for word in review.lower().split() if word not in stoplist]
            try:
                corpus.append(texts)
            except:
                pass
    print "Size of corpus:", len(corpus)

    # Build dictionary
    dictionary = corpora.Dictionary(corpus)
    dictionary.save('LDA/restaurant_reviews.dict')

    # Build vectorized corpus
    corpus_2 = [dictionary.doc2bow(text) for text in corpus]
    corpora.MmCorpus.serialize('LDA/restaurant_reviews.mm', corpus_2)
    
    lda = models.LdaModel(corpus_2, num_topics=k, id2word=dictionary)
    lda_topics = lda.show_topics(num_topics=30, num_words=10, log=False, formatted=True)
    
    # Save LDA model to file
    lda.save('LDA/lda_model')

    # Save topics and terms to file
    file_lda = open("LDA/lda_topics.txt", mode = "w")
    count = 1
    for topic in lda_topics:
        topic = re.sub(r'[^a-z\s]', "", topic)
        topic = re.sub(" + ", ", ", topic)
        data_str = "Topic {0}: {1}\n".format(str(count), topic)
        print data_str
        file_lda.write(data_str.encode('utf-8'))
        count += 1
    file_lda.close()
# Just load previous LDA model
else:
    print "Loading LDA model..."
    lda = models.LdaModel.load('LDA/lda_model')
    dictionary = corpora.dictionary.Dictionary.load('LDA/restaurant_reviews.dict')
    f = open("LDA/lda_topics.txt", mode = "r")
    for line in f:
        print line
    f.close()
```
* Top 30 topics:
Topic 1: beer, selection, beers, tap, local, draft, cold, bar, ale, pies
Topic 2: location, times, years, new, still, since, few, last, used, time
Topic 3: chicken, sauce, fried, pork, rice, beef, flavor, meat, bbq, shrimp
Topic 4: oil, fork, olive, feta, grease, children, flatbread, mon, karaoke, black
Topic 5: pho, spring, vietnamese, rolls, vegas, san, broth, mi, best, bowl
Topic 6: thai, soup, chinese, tea, curry, noodles, spicy, rice, dishes, dish
Topic 7: coffee, brunch, sunday, hash, morning, french, cafe, bagel, bloody, breakfast
Topic 8: breakfast, eggs, bacon, toast, pancakes, egg, potatoes, gravy, french, sausage
Topic 9: steak, ordered, dinner, meal, service, delicious, dessert, dish, cooked, lobster
Topic 10: wall, hole, store, consistently, und, grocery, das, der, ich, mahi
Topic 11: pizza, italian, crust, cheese, sauce, pasta, pizzas, pie, slice, thin
Topic 12: sushi, roll, rolls, fish, tuna, fresh, salmon, sashimi, chef, ayce
Topic 13: bar, wine, night, drinks, bartender, drink, glass, happy, dinner, bottle
Topic 14: time, service, order, minutes, ordered, table, asked, took, server, wait
Topic 15: old, school, something, high, madison, feel, head, express, off, life
Topic 16: de, la, le, et, un, est, pour, les, en, une
Topic 17: es, j, avec, h, killer, ed, caf, id, tait, el
Topic 18: buffet, better, price, vegas, pretty, eat, bad, nothing, quality, worth
Topic 19: tacos, mexican, chips, salsa, taco, burrito, beans, fish, carne, guacamole
Topic 20: yelp, margarita, photos, nachos, quesadilla, select, yum, def, rocks, biz
Topic 21: bar, night, people, pretty, outside, area, patio, music, little, inside
Topic 22: strip, hotel, shop, mall, casino, dollar, located, vegas, pittsburgh, resort
Topic 23: service, love, best, friendly, time, staff, amazing, delicious, definitely, recommend
Topic 24: menu, options, find, items, friendly, vegetarian, quite, area, priced, vegan
Topic 25: salad, chicken, lunch, bread, fresh, delicious, soup, sandwich, ordered, side
Topic 26: burger, fries, sandwich, cheese, burgers, sandwiches, potato, bacon, ordered, onion
Topic 27: hot, wings, dog, chicken, korean, dogs, sauce, spicy, hawaiian, buffalo
Topic 28: cream, ice, chocolate, dessert, cake, indian, sweet, desserts, banana, delicious
Topic 29: die, pub, irish, ist, man, dancing, site, pollo, hooters, definately
Topic 30: experience, review, reviews, owner, yelp, party, business, birthday, card, manager
    
**Get topic proportion for every star**

```
# Process a review set by stripping non-alphabetical characters and removing stopwords
def process_reviews(dirty_data_set):
    clean_data_set = []
    for review in dirty_data_set:
        if (len(review) > 100):
            # Remove punctuations
            review = re.sub(r'[^a-zA-Z]', ' ', review)
            # To lowercase
            review = review.lower()
            # Remove stop words
            texts = [word for word in review.lower().split() if word not in stoplist]
            try:
                clean_data_set.append(' '.join(texts))
            except:
                pass
    return clean_data_set

# Generates a matrix of topic probabilities for each document in matrix
# Returns topic_dist for the input corpus, and all_dist, a running sum of all the corpuses
def generate_topic_dist_matrix(corpus, all_dist, star):
    topic_dist = [0] * k
    for doc in corpus:
        vec = dictionary.doc2bow(doc.lower().split())
        output = lda[vec]
        highest_prob = 0; highest_topic = 0
        temp = [0] * k    # List to keep track of topic distribution for each document
        for topic in output:
            this_topic, this_prob = topic
            temp[this_topic] = this_prob
            if this_prob > highest_prob:
                highest_prob = this_prob 
                highest_topic = this_topic
        temp.append(star)
        all_dist.append(temp)
        topic_dist[highest_topic] += 1
    return topic_dist, all_dist
 ```
* Topic proportion for star one to star five:
Topic distribution for 5-star reviews in test set:  [97, 1056, 1601, 10, 96, 812, 181, 378, 5113, 3, 1185, 307, 338, 2200, 108, 154, 5, 1803, 957, 13, 1808, 15, 11597, 1155, 2017, 1887, 146, 347, 64, 399]
Topic distribution for 4-star reviews in test set:  [95, 1176, 2389, 7, 119, 1168, 145, 455, 3967, 2, 1113, 339, 387, 3313, 109, 220, 6, 3197, 987, 13, 3636, 13, 6485, 1432, 2654, 2543, 130, 234, 72, 277]
Topic distribution for 3-star reviews in test set:  [77, 1421, 2805, 8, 96, 976, 92, 384, 2670, 1, 880, 237, 249, 6736, 93, 217, 6, 7412, 776, 20, 3785, 10, 2600, 1052, 1651, 2559, 89, 125, 93, 253]
Topic distribution for 2-star reviews in test set:  [39, 1441, 2801, 13, 56, 631, 39, 212, 1810, 0, 796, 224, 138, 13362, 111, 138, 1, 8666, 603, 5, 1802, 4, 1037, 448, 940, 1852, 60, 67, 76, 316]
Topic distribution for 1-star reviews in test set:  [21, 1294, 1779, 35, 26, 329, 20, 143, 693, 2, 621, 114, 90, 21319, 92, 105, 5, 6071, 381, 0, 903, 9, 477, 197, 445, 975, 37, 36, 59, 892]
**Visualize topic proportion for every star by shiny:
  [wordcloud]: https://claire-yl3296-presentation.shinyapps.io/wordcloud/

