## Merge final export from Blackboard to template for batch upload to Banner
## For University of South Carolina instructors
## Since the university doesn't have this functionality built in to simply transfer Blackboard grades

library(tidyverse)
library(readxl)
library(here)
library(writexl)

## Remember to download the Blackboard grades as LETTERS not NUMBERS

## Store the filename of the Banner export
banner_filename <- "202308_CRJU - Criminal Justice_314_002_Template.xlsx"

## Read in Banner (i.e., USC export from Banner grade system) and Blackboard data
banner <- read_excel("USC grade merge/202308_CRJU - Criminal Justice_314_002_Template.xlsx")

# read in the blackboard dataset and rename Final Grade to BB_Final_Grade
blackboard <- rio::import("USC grade merge/fall 2023 blackboard grades.xlsx") %>%
  # override weird Blackboard export naming the Overall Grade
  rename('Final Grade' = 'Overall Grade [Total Pts: up to 501 Letter] |6686369') 

# Only needed if you have a scheme that exports with "minus" grades
# Remove the minus grades from the Final Grade column in the blackboard dataset
# blackboard <- blackboard %>%
#   mutate(`Final Grade` = str_replace_all(`Final Grade`, "-$", ""))

# merge the datasets based on Student ID
merged_data <- banner %>%
  left_join(blackboard %>% select("Student ID", "Final Grade"), by = "Student ID") %>%
  mutate("Final Grade" = coalesce(`Final Grade.x`, `Final Grade.y`)) %>%
  select(-`Final Grade.x`, -`Final Grade.y`)

## Rearrange columns to match the original banner object
merged_data <- merged_data %>%
  select(`Term Code`, CRN, `Full Name`, `Student ID`, Rolled, Confidential, Course,
         `Final Grade`, `Last Attended Date`, `Incomplete Final Grade`, `Extension Date`, `Extension Date Constraints`)

#

## Create a new filename with "_merged" appended
merged_filename <- sub("\\.xlsx", "_merged.xlsx", banner_filename)

## Export merged data back into the original named template for record keeping
write_xlsx(merged_data, here("USC grade merge", merged_filename))


## Now go back to Banner, import your merged data
