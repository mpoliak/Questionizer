# Questionizer
Questionizer is a survey creation tool for language experiments. It reads a csv file with the experimental items and a csv file with consent, demographics, and instructions, and outputs a .txt file that can be uploaded to Qualtrics to generate a survey (Qualtrics is an online survey platform that many American universities are already subscribed to).

## Main Features
1. Produces Qualtrics-compatible .txt file.
2. Supports polar questions, Likert items, and open text questions.
3. Generates a Lating Square design.
4. Contains data wrangling code that puts data from Qualtrics in a convenient format for analysis.

## Contents:
* `questionizer.R`: turns two .csv files into a .txt file that can be uploaded on Qualtrics to generate an experiment.
* `data_wrangling.R`: parses data from Qualtrics into a convenient format (only works for surveys that were generated using Questionizer).
* `stimuli_turkolizer_to_questionizer.R`: turns a .txt file in Turkolizer format to a .csv stimuli file for Questionizer.
* `sample_survey_properties.csv`: sample questions like demographics and consent.
* `sample_stimuli.csv`: sample stimuli in the Questionizer format.
* `turkformat_stimuli.txt`: sample stimuli in the Turkolizer format.

## Usage
1. In the same folder as the scripts, create a csv file for stimuli and a csv file for the head block (for consent, demographics, etc.; see below for more information).
2. Open `questionizer.R`, and specify the name of the stimuli .csv file and the name of the head block .csv file (make sure to change the headblock to include your details on the consent form). If you are using binary response questions in a language other than English, exchange "yes" and "no" for the corresponding words in your study's language. Then run the entire script, which will output the file `qualtrics_survey.txt` in the same folder.
3. Go on Qualtrics, create an empty survey, and, on the survey page, click on Tools->Import/Export->Import Survey, and upload the file that was just created (`qualtrics_survey.txt`). This may take a few minutes because Qualtrics takes some time to parse the file (refreshing does not stop the process). *Nota Bene*: If you have many questions and lists (questions\*lists > 1000), Qualtrics may get stuck when creating the survey. Simply refresh, see which lists were not uploaded, and reupload a version of the .txt file without the lists that have been successfully uploaded.
4. **THIS IS A CRITICAL STAGE ON QUALTRICS. DON'T MISS THIS**: 
* Equal assignment of participants: Go into "Survey Flow" on the left side of the survey page on Qualtrics. Scroll to the bottom and choose "Add a New Element Here". Choose "Randomizer." Then, move all the blocks except "headerBlock" into the randomizer (drag and drop). Choose to randomly present **1** of the following elements and tick the "Evenly Present Elements" box. If you don't choose 1 or don't tick the box, participants will be exposed to more than one list or the lists will have unequal number of participants (respectively). Click "Apply."
5. Once the data are collected, you can download them from the tab "Data & Analysis" and export the data in .csv format, downloading all fields using choice text (the default settings on Qualtrics). Unzip the data in the same folder with `data_wrangling.R` and run the script (after specifying the file name) to reshape the data into a convenient format.

## Details about input
The code takes two files. One file for survey properties (basically, consent, demographics, and instructions) and one file for stimuli. Customization in questionizer is somewhat limited, but further customization is available once the questionnaire is uploaded to Qualtrics.

### Consent, demographics, and instructions
This lets you create a block that all participants will see. This is good for stuff like consent, demographics, and instructions. However, you can customize this block to look in a bunch of different ways. Each block consists of questions (a row in the .csv input file), and each question needs to have its presentation order, name, type, and content (options is optional). The supported question types are "text," "question_text," and "question_choices." 
* text: simply displays text to the participant with no option to respond. Good for consent and instructions.
* question_text: lets participants type in whatever they want. Good for getting their participant_ID from whatever crowd-sourcing platform you are using.
* question_choices: lets participants respond to a multiple choice question, and the options need to be specified in the options column, separated by underscores ("\_").

For an example, consider the file `sample_survey_properties.csv`

### Stimuli
This lets you create the questionnaire lists that participants see. For each question, you need to specify experiment, item, condition, sentence, prompt, question_type, and literal_response.

The number of lists that will be created is equal to the lest common multiple of the number of conditions of all experiments.

The question types are binary, likertN (with 1 < x < 10), and completion. 
* binary: these are polar questions, to which participants respond either Yes or No. Put under the `sentence` column the sentence that you want participants to see, and under the `prompt` the question that you want them to see with this sentence. Under `literal_response` provide the answer that would indicate a literal interpretation (or, in other paradigms, whatever the correct answer is to the item, Yes or No).
* likertN: under `sentence`, provide what you want to display to the participants, and under `prompt` provide the labels for the Likert scale (e.g., "Ungrammatical_Grammatical"). Write NA under `literal_response`, it's not useful here.
* completion: under `sentence`, provide the sentence that you want to display to the participants, and under `prompt` provide the instructions for participants (e.g., "complete the sentence"). Write NA under `literal_response`, it's not useful here.

In the case that you already have past stimuli for binary response in TURKOLIZER .txt format, use the `stimuli_turkolizer_to_questionizer.R` script to convert them to the .csv format.

For an example, consider the files `sample_stimuli.csv` and `turkformat_stimuli.txt`

 ## Important notes:
 1. Keep experiment and condition names (as well as other parameters) short. If they're too long, Qualtrics will truncate them and you will not be able to recover your data (at least not easily).
 2. Always have the first question that requires user input in the survey properties called participant_ID, else the analysis script won't work for you.
 3. Always test the survey on yourself several times and on colleagues and analyze the resulting data before collecting the real data. This will save you a lot of heartache and money.