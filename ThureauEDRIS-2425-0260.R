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

Deaths_Full <- read.xlsx('//conf/quality/srr/Active/(04) Project Reports/Annual Reports/2025/Extracts/Deaths_Full.xlsx', detectDates = T)
SRR_Patients <- read.xlsx('//conf/quality/srr/Active/(04) Project Reports/Annual Reports/2025/Extracts/SRR_Patients_Static.xlsx', detectDates = T)

SRR_Data <- left_join(SRR_Patients, Deaths_Full, by = 'chi_formatted')

FullDatabase <- scidc_cohort %>% 
  inner_join(SRR_Data, by = 'chi_formatted') 

OutputData <- FullDatabase %>% 
  filter(StartKRT > '1981-01-01') %>% 
  select(id, chi_formatted, FormattedPostcode, StartKRT, First_Type, First_Unit, PRD_Code, Sex = Gender,
         Type_Transplant, dt_1st_tx_failed, source_transplant = DBD_DCD_LRD_LUD, date_of_death.y, Ethnicity, 
         date_first_referral, KRTChangeDate = date1, RRT.Modality, Last_Unit)


#missing: DateTx,dt_tx_status, simd_2020v2_sc_decile, quintile
