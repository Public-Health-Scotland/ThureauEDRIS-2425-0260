#Thureau Diabetes IR
#Written in R 4.5.1
#Written 26/2/2026
#By Alex Blanchard

library(tidyverse)
library(lubridate)
library(zoo)
library(openxlsx)
library(janitor)
library(readr)
library(dplyr)
library(openxlsx)

 rm(list = ls(all = TRUE)) # Clear workspace

OutputFolder <-  "//conf/quality/srr/Active/(04) Project Reports/Information Requests/2025/eDRIS 2425-0260 (repeat of 2324-0050&1617-0147)/"

#Read in external cohort Data ----
external_cohort_folder <- paste0(OutputFolder,'2425-0260-scidc-type1.csv.xz')
scidc_cohort <- readr::read_csv(external_cohort_folder, col_types = 'cc') %>% 
  rename(chi_formatted = upi)

#Read in SRR databases

Deaths_Full <- read.xlsx('//conf/quality/srr/Active/(04) Project Reports/Annual Reports/2026/Extracts/Deaths_Full.xlsx', detectDates = T)
SRR_Patients <- read.xlsx('//conf/quality/srr/Active/(04) Project Reports/Annual Reports/2026/Extracts/SRR_Patients_Static.xlsx', detectDates = T)

SRR_Data <- left_join(SRR_Patients, Deaths_Full, by = 'chi_formatted')

FullDatabase <- scidc_cohort %>% 
  inner_join(SRR_Data, by = 'chi_formatted') 

OutputData <- FullDatabase %>% 
  filter(StartKRT > '1981-01-01') %>% 
  filter(date1 < '2024-12-31') %>% 
  select(id, chi_formatted, FormattedPostcode, StartKRT, First_Type, First_Unit, PRD_Code, Sex = Gender,
         Type_Transplant, dt_1st_tx_failed, source_transplant = DBD_DCD_LRD_LUD, Date_Of_Death = date_of_death.y, Ethnicity, 
         date_first_referral, KRTChangeDate = date1, RRT.Modality, Last_Unit)


#missing: dt_tx_status, simd_2020v2_sc_decile, quintile
#technically missing tx_date but those data are included in the DDT Modality change when a tx occurs.


Wb <-  createWorkbook(title = NULL, subject = NULL, category = NULL)

#create worksheets 
addWorksheet(
  wb = Wb,
  sheetName = "Output Data",
  gridLines = TRUE,
  zoom = 100,
  visible = TRUE
)

#writing in data 
writeData(
  # Name of the workbook we want to add the sheet to
  wb = Wb,
  # Name of tab to save the data to 
  sheet = "Output Data", 
  # Name of the dataset we want to write out
  OutputData, 
  # Column we want the data to start from
  startCol = 1,
  # Row we want the data to start from 
  startRow = 1 
)


saveWorkbook(
  wb = Wb,
  # File path to save out 
  file = paste0(OutputFolder,'/ThureaduEDRIS-2425-0260_OutputDataV2.xlsx'),
  overwrite = TRUE
)
