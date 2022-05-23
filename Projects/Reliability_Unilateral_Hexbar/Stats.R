setwd(dirname(rstudioapi::getSourceEditorContext()[['path']]))

library(rstatix)
library(tidyverse)
library(data.table)

data = read_csv('StrengthData.csv')

# Create uniquley identfied column
data.id <- data %>% 
  unite('ID', group, id, remove = FALSE) %>% 
  select(-id)

# Pivoting data
data.superlong <- data.id %>% 
  pivot_longer(-c(ID, group), names_to =c('test','time'), names_sep = '_', values_to = 'force')

data.justlong <- data.superlong %>% 
  pivot_wider(names_from = 'test', values_from = 'force')

# Mean difference
MD <- data.superlong %>% 
  select(-ID) %>% 
  group_by(group, test, time) %>% 
  summarise('mean' = mean(force)) %>% 
  ungroup() %>% 
  pivot_wider(names_from = time, values_from = mean) %>%
  mutate('mean_difference' = (Post - Pre)/Pre*100)
write.csv(MD,"Mean_Strength.csv")


# Normality 
A = data.justlong %>% group_by(group) %>% shapiro_test(HE,HF,HAB,HAD,HER,HIR)
write.csv(A,"Normality_Strength.csv")


# Mixed ANOVA
HE = anova_test(data = data.justlong, dv = HE, wid = ID, within = time, between = group, detailed = TRUE)
HF = anova_test(data = data.justlong, dv = HF, wid = ID, within = time, between = group, detailed = TRUE)
HAB = anova_test(data = data.justlong, dv = HAB, wid = ID, within = time, between = group, detailed = TRUE)
HAD = anova_test(data = data.justlong, dv = HAD, wid = ID, within = time, between = group, detailed = TRUE)
HER = anova_test(data = data.justlong, dv = HER, wid = ID, within = time, between = group, detailed = TRUE)
HIR = anova_test(data = data.justlong, dv = HIR, wid = ID, within = time, between = group, detailed = TRUE)

# ANOVA fro all the parameters 
A = data.table(Effect = HE %>% pull(Effect),
               HE= HE %>% pull(p),HF=HF %>% pull(p),HAB=HAB%>% pull(p),
               HAD=HAD%>% pull(p),HER=HER%>% pull(p),HIR=HIR%>% pull(p))
write.csv(A,"ANOVA_Strength.csv")


###########################
# Posthoc - Paired t-test #
###########################
HE = data.justlong %>% group_by(group) %>% 
  pairwise_t_test(HE ~ time, paired = TRUE,p.adjust.method = "bonferroni",detailed = FALSE)

HAB = data.justlong %>% group_by(group) %>% 
  pairwise_t_test(HAB ~ time, paired = TRUE,p.adjust.method = "bonferroni",detailed = FALSE)

HAD = data.justlong %>% group_by(group) %>% 
  pairwise_t_test(HAD ~ time, paired = TRUE,p.adjust.method = "bonferroni",detailed = FALSE)

HER = data.justlong %>% group_by(group) %>% 
  pairwise_t_test(HER ~ time, paired = TRUE,p.adjust.method = "bonferroni",detailed = FALSE)

HIR = data.justlong %>% group_by(group) %>% 
  pairwise_t_test(HIR ~ time, paired = TRUE,p.adjust.method = "bonferroni",detailed = FALSE)

# Posthoc - wilcox_test (PAIRED)
HF = data.justlong %>% group_by(group) %>% 
  pairwise_wilcox_test(HF ~ time, paired = TRUE,p.adjust.method = "bonferroni",detailed = FALSE)

# Save 
A = data.table(Group = HE%>% pull(group), Time1 = HE%>% pull(group1), Time1 = HE%>% pull(group2),
               HE= HE%>% pull(p.adj),HF=HF %>% pull(p.adj),HAB=HAB%>% pull(p.adj),
               HAD=HAD%>% pull(p.adj),HER=HER%>% pull(p.adj),HIR=HIR%>% pull(p.adj))
write.csv(A,"PostHoc_Time_Strength.csv")

################################
# Posthoc - independent t-test #
################################
HE = data.justlong %>% group_by(time) %>% 
  pairwise_t_test(HE ~ group, paired = FALSE,p.adjust.method = "bonferroni",detailed = FALSE)
HAB = data.justlong %>% group_by(time) %>% 
  pairwise_t_test(HAB ~ group, paired = FALSE,p.adjust.method = "bonferroni",detailed = FALSE)
HAD = data.justlong %>% group_by(time) %>% 
  pairwise_t_test(HAD ~ group, paired = FALSE,p.adjust.method = "bonferroni",detailed = FALSE)
HER = data.justlong %>% group_by(time) %>% 
  pairwise_t_test(HER ~ group, paired = FALSE,p.adjust.method = "bonferroni",detailed = FALSE)
HIR = data.justlong %>% group_by(time) %>% 
  pairwise_t_test(HIR ~ group, paired = FALSE,p.adjust.method = "bonferroni",detailed = FALSE)

# Posthoc - wilcox_test (independent)
HF =data.justlong %>% group_by(time) %>% 
  pairwise_wilcox_test(HF ~ group, paired = FALSE,p.adjust.method = "bonferroni",detailed = FALSE)

# Save 
A = data.table(Time = HE%>% pull(time), Group1 = HE%>% pull(group1), Group2 = HE%>% pull(group2),
               HE= HE%>% pull(p.adj),HF=HF %>% pull(p.adj),HAB=HAB%>% pull(p.adj),
               HAD=HAD%>% pull(p.adj),HER=HER%>% pull(p.adj),HIR=HIR%>% pull(p.adj))
write.csv(A,"PostHoc_Group_Strength.csv")
