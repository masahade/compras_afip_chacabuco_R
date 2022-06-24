library(stringr)
library(tidyverse)
library(dplyr)
library(lubridate)
library(writexl)
library(readxl)
library(purrr)
library(openxlsx)


setwd("C:/projectoR/Compras_Chacabuco_AFIP")


camino='data'

files= dir(path = camino, pattern = ".*30694267552.*\\.xlsx$",
           full.names = TRUE, recursive = TRUE)

df=tibble(read_excel(files[1], skip = 1)) # SOLO TOMARA EL PRIMER ARCHIVO DE LA LISTA

df <- df %>% mutate(Fecha=as.Date(Fecha, format = "%d/%m/%Y"))

names(df) = c('Fecha','Tipo','Punto_Venta','Numero',
                    'Hasta','Codigo','Tipo_doc','CUIT','Proveedor',
                     'TC','Moneda','Neto_Gravado',
                    'No_Gravado','Exento','IVA','Total')

df <- df %>% select(-c('Hasta','Codigo'))


cond=str_detect(df$Tipo,'Nota de Crédito')

df$Neto_Gravado <- df$Neto_Gravado * df$TC
df$No_Gravado <- df$No_Gravado * df$TC
df$IVA <- df$IVA * df$TC
df$Exento <- df$Exento * df$TC
df$Total <- df$Total * df$TC

# si quisiera usar dplyr para pasar a engativo las Notas de credito
# df <- df %>% mutate(Total = ifelse(cond,Total*-1,Total))

df[cond,c('Neto_Gravado')]<-df[cond,c('Neto_Gravado')]*-1
df[cond,c('No_Gravado')]<-df[cond,c('No_Gravado')]*-1
df[cond,c('Exento')]<-df[cond,c('Exento')]*-1
df[cond,c('IVA')]<-df[cond,c('IVA')]*-1
df[cond,c('Total')]<-df[cond,c('Total')]*-1

df <- df %>% select(-c('Tipo_doc','TC'))
df <- df %>% arrange(Proveedor,Fecha)


write_xlsx(df, 'output/compras_Chacabuco.xlsx')

