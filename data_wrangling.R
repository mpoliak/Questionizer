library(tidyverse)
library(rstudioapi)

## Set Path
setwd(dirname(getActiveDocumentContext()$path))    ## sets dir to R script path

## Load data
dat <- read_csv("data.csv")

## Data wrangling
## Remove Prolific data
dat <- dat[-c(1,2),-(1:17)]

## Save Question Names (data, not demographics)
survey_names <- names(dat)[substr(names(dat), 0, 5) == "list_"]

## Save the demographic data for later
part_dat <- dat %>% 
  select(names(dat)[!names(dat) %in% survey_names])

## Encode participant ID in all data cells
for (i in 1:nrow(dat)) {
  dat[i,] <- t(as.data.frame(paste(dat[i,], dat$participant_ID[i], sep="_SEP_")))
}

## Stay with data only (no demographics)
survey <- dat %>% select(survey_names)

## Reshape
survey <- survey %>%
  pivot_longer(cols=everything()) %>%
  separate(name, sep="\\.", into = c("list", "order", "experiment",
                                     "item", "condition", "literal")) %>%
  mutate(list = as.factor(substr(list, 6, nchar(list))),
         order = as.factor(substr(order, 7, nchar(order))),
         experiment = as.factor(substr(experiment, 5, nchar(experiment))),
         item = as.factor(substr(item, 6, nchar(item))),
         condition = as.factor(substr(condition, 6, nchar(condition))),
         literal = as.factor(substr(literal, 5, nchar(literal)))) %>%
  separate(value, sep="_SEP_", into=c("response", "participant_ID")) %>%
  mutate(response = ifelse(response == "NA", NA, response),
         participant_ID = as.factor(participant_ID)) %>%
  na.omit()


## Combine with participant data
dat <- survey %>% 
  left_join(part_dat %>% 
              select(names(dat)[!names(dat) %in% survey_names]),
            on = "participant_ID") %>%
  mutate(participant_ID = as.factor(participant_ID))

## -- Simple descriptives --
head(dat)

## Items per experiment per participant
table(dat$experiment, dat$participant_ID)

## Participants per list
dat %>%
  select(list, participant_ID) %>%
  distinct() %>%
  group_by(list) %>%
  summarize(number_of_participants = n())

## ---- Analysis ----

## That's up to you :)


