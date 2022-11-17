library(tidyverse)
library(rstudioapi)

## Set Path
setwd(dirname(getActiveDocumentContext()$path))    ## sets dir to R script path

## ------ INPUT USER PARAMETERS HERE ------- ##
file_name <- "turkformat_stimuli.txt"

## ----- Parse stimuli -----
## Open file
con = file(file_name, "r")

## Create empty dataframe
stimuli <- tibble(
  experiment = character(),
  item = character(),
  condition = character(),
  sentence = character(),
  prompt = character(),
  literal_response = character()
)

## Set dataframe row counter
counter <- 0

while (TRUE) {
  ## Read line
  line = readLines(con, n = 1)
  
  ## If the end of the document, finish and close file
  if (length(line) == 0) {
    break
  }
  
  ## Extract line code (sentence, prompt, etc.)
  code <- substr(line, 1, 1)
  
  ## Populate dataframe with data from text file.
  if (code == "#") {
    counter <- counter + 1
    line <- strsplit(line, " ")[[1]]
    stimuli[counter, ]$experiment <- line[2]
    stimuli[counter, ]$item <- line[3]
    stimuli[counter, ]$condition <- line[4] 
  } else if (code %in% c(LETTERS, letters)) {
    stimuli[counter, ]$sentence <- line 
  } else if (code == "?")  {
    line <- str_trim(strsplit(line, "\\?")[[1]])
    stimuli[counter, ]$prompt <- paste(line[2], "?", sep="")
    stimuli[counter, ]$literal_response <- line[3]
  } else if (code == "") {
    next
  } else {
    print(paste("failure on line", counter))
  }
}

## Add question type
stimuli$question_type <- "binary"

## Change order of columns
stimuli[,8] <- stimuli[,6]
stimuli[,6] <- stimuli[,7]
stimuli[,7] <- stimuli[,8]
stimuli <- stimuli[,1:7]
names(stimuli)[c(6, 7)] <- names(stimuli)[c(7, 6)]

write_csv(stimuli, file="from_turkformat.csv")
