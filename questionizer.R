if (!require("tidyverse")) {install.packages("tidyverse"); require("tidyverse")} 
if (!require("rstudioapi")) {install.packages("rstudioapi"); require("rstudioapi")} 
if (!require("numbers")) {install.packages("numbers"); require("numbers")} 

## Set Path
setwd(dirname(getActiveDocumentContext()$path))    ## sets dir to R script path

## ---- Input User Parameters ---- ##
stimuli_filename <- "sample_stimuli.csv"
survey_properties_filename <- "sample_survey_properties.csv"
yesno <- c("Yes", "No") ## (Change according to language)
## ---- --------------------- ---- ##
## Load data
stimuli <- read_csv(stimuli_filename)
survey <- read_csv(survey_properties_filename)

## Report Summary of data
print("Experiments: ")
table(stimuli$experiment)

print("Conditions: ")
table(stimuli$condition)

print("Question Types: ")
table(stimuli$question_type)

## Test that the number of items in each experiment is a multiple of the number
## of conditions
for (i in 1:length(unique(stimuli$experiment))) { 
  temp <- stimuli %>% filter(experiment == unique(stimuli$experiment)[i])
  if (length(unique(temp$item)) %% length(unique(temp$condition)) != 0) {
    stop(paste("The number of items in Experiment ", temp$experiment[1], 
               " is not a multiple of the number of conditions.", sep=""))
  }
}

## ----- Create Lists -----
## Lowest common denominator of number of conditions per experiment
n_lists <- stimuli %>%
  select(experiment, condition) %>%
  distinct() %>%
  group_by(experiment) %>%
  summarize(n_conds = n()) %>%
  pull(n_conds) %>%
  numbers::mLCM()

lists <- tibble(list_id = numeric(),
                experiment = character(),
                item = numeric(),
                condition = character())

## Repeat for each experiment
for (i in 1:length(unique(stimuli$experiment))) {
  temp <- stimuli %>% filter(experiment == unique(stimuli$experiment)[i])
  
  ## Generate list of items per list
  for (j in 1:n_lists) {
    list_id <- rep(j, length(unique(temp$item)))
    experiment <- rep(unique(stimuli$experiment)[i], length(unique(temp$item)))
    ## Get list of items
    items <- temp$item %>% unique()
    ## Get list of Conditions
    conditions <- vector()
    for (k in 1:length(items)) {
      conditions <- c(conditions, unique(temp$condition)[(j+k) %% length(unique(temp$condition)) + 1])
    }

    lists <- bind_rows(lists,
                       tibble(
                         list_id = list_id,
                         experiment = experiment,
                         item = items,
                         condition = conditions
                         )
                      )
    }
  
}

lists <- lists %>%
  left_join(stimuli, on = c("experiment", "item", "condition")) %>%
  arrange(list_id, experiment, item)

## ----- Create Qualtrics survey -----
## Create lists and print in text document for Qualtrics
cprint <- function(your_string) {
  cat(your_string, "\n")
}

sink("qualtrics_survey.txt")

cprint("[[AdvancedFormat]]")
cprint("[[Block:headerBlock]]")

## Print head data (e.g., demographics, instructions)
survey <- survey[sort(survey$order),]
for (i in 1:nrow(survey)) {
  if (survey$type[i] == "text") {
    cprint("[[Question:DB]]")
    cprint(paste("[[ID:", survey$name[i],"]]", sep=""))
    cprint(survey$content[i])
  } else if (survey$type[i] == "question_text") {
    cprint("[[Question:TE:SingleLine]]")
    cprint(paste("[[ID:", survey$name[i],"]]", sep=""))
    cprint(survey$content[i])
  } else if (survey$type[i] == "question_choices") {
    choices <- strsplit(survey$options[i], split="_") %>% unlist()
    cprint("[[Question:MC:SingleAnswer:Horizontal]]")
    cprint(paste("[[ID:", survey$name[i],"]]", sep=""))
    cprint(survey$content[i])
    cprint("[[AdvancedChoices]]")
    for (j in 1:length(choices)) {
      cprint("[[Choice]]")
      cprint(choices[j])
    }
  } else {
    stop("Error in Survey Properties Format")
  }
}

for (i in 1:length(unique(lists$list_id))) {
  ## New list
  cprint(paste("[[Block:", "list_", i, "]]", sep=""))
  
  ## Get one list and randomize
  temp <- lists %>% filter(list_id == i)
  temp <- temp[sample(1:nrow(temp)),]
  
  ## Write entire list block
  for (j in 1:nrow(temp)) {
    ## In case of binary response
    if (temp$question_type[j] == "binary") {
      cprint("[[Question:MC:SingleAnswer:Horizontal]]")
      cprint(paste("[[ID:", "list_", i, ".order_", j,
                   ".exp_", temp$experiment[j],
                   ".item_", temp$item[j], ".cond_", temp$condition[j], 
                   ".lit_", temp$literal_response[j], "]]", sep=""))
      cprint(temp$sentence[j])
      cprint("<br>")
      cprint(temp$prompt[j])
      cprint("[[AdvancedChoices]]")
      cprint("[[Choice]]")
      cprint(yesno[1])
      cprint("[[Choice]]")
      cprint(yesno[2])
    ## In case of Likert item
    } else if (substr(temp$question_type[j], 1, 6) == "likert") {
      steps <- as.numeric(substr(temp$question_type[j], 7, 7))
      edges <- strsplit(temp$prompt[j], split="_") %>% unlist()
      cprint("[[Question:MC:SingleAnswer:Horizontal]]")
      cprint(paste("[[ID:", "list_", i, ".order_", j,
                   ".exp_", temp$experiment[j],
                   ".item_", temp$item[j], ".cond_", temp$condition[j], 
                   ".lit_", temp$literal_response[j], "]]", sep=""))
      cprint(temp$sentence[j])
      cprint("<br>")
      cprint("[[AdvancedChoices]]")
      for (j in 1:steps) {
        cprint("[[Choice]]")
        if (j == 1)
        {
          cprint(paste(edges[1], "<br>", j, sep=""))
        } else if (j == steps) {
          cprint(paste(edges[2], "<br>", j, sep=""))
        } else {
          cprint(j)
        }
      }
    } else if (temp$question_type[j] == "completion") {
      cprint("[[Question:TE:SingleLine]]")
      cprint(paste("[[ID:", "list_", i, ".order_", j,
                   ".exp_", temp$experiment[j],
                   ".item_", temp$item[j], ".cond_", temp$condition[j], 
                   ".lit_", temp$literal_response[j], "]]", sep=""))
      cprint(temp$sentence[j])
      cprint("<br><br>")
      cprint(temp$prompt[j])
    } else {
      stop("Error in Stimuli Format")
    }
  }
}

sink()
