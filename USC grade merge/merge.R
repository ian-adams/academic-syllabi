## Merge final export from Blackboard to template for batch upload to Banner
## For University of South Carolina instructors
## Since the university doesn't have this functionality built in to simply transfer Blackboard grades

library(tidyverse)
library(readxl)
library(here)
library(writexl)

## Remember to download the Blackboard grades as LETTERS not NUMBERS

## Store the filename of the Banner export
banner_filename <- "202305_CRJU - Criminal Justice_311_J11_Template.xlsx"

## Read in Banner (i.e., USC export from Banner grade system) and Blackboard data
banner <- read_excel("USC grade merge/202305_CRJU - Criminal Justice_311_J11_Template.xlsx")

# read in the blackboard dataset and rename Final Grade to BB_Final_Grade
blackboard <- read_excel("USC grade merge/gc_CRJU311-J11-SUMMER-2023_fullgc_2023-07-30-19-50-15.xlsx") %>%
  # override weird Blackboard export naming the Overall Grade
  rename('Final Grade' = 'Overall Grade [Total Pts: up to 492 Letter] |6610433') 

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
