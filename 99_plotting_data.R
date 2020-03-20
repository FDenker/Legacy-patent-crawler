require(ggplot2)
reg_schutzrecht <- lm(as.numeric(day_difference) ~ Schutzrecht,uspto_dpma_register_join)
summary(reg_schutzrecht)  

reg_year <- lm(as.numeric(year_difference) ~ patent_year, uspto_depatisnet_join)
summary(reg_year)


uspto_depatisnet_join %>%  group_by(.$patent_year) %>% 
  summarise(count=n()) %>% as.data.frame() %>% 
  ggplot(aes(.[,1],count, group=1)) + geom_path()

uspto_depatisnet_join %>%  group_by(.$application_year_fp) %>% 
  summarise(count=n()) %>% as.data.frame() %>% 
  ggplot(aes(.[,1],count, group=1)) + geom_path()

yearly_application_numbers_us<- uspto_depatisnet_join %>%  group_by(.$patent_year) %>% 
  summarise(count=n()) %>% as.data.frame()

yearly_application_numbers_de <- uspto_depatisnet_join %>% 
  group_by(.$application_year_fp) %>% 
  summarise(count=n()) %>% as.data.frame()

yearly_application_numbers_joined<- full_join(yearly_application_numbers_us, yearly_application_numbers_de, by=c(".$patent_year"=".$application_year_fp"))
  
ggplot() + geom_path(data=yearly_application_numbers_joined, aes(yearly_application_numbers_joined[,1],yearly_application_numbers_joined[,2], group=1, colour="USPTO")) +
  geom_path(data=yearly_application_numbers_joined, aes(yearly_application_numbers_joined[,1],yearly_application_numbers_joined[,3], group=1))

ggplot(data=uspto_dpma_register_join,  aes(day_difference, group=type_of_ip, colour=type_of_ip)) + 
  geom_density() +xlab("Age of german patent/utility model cited (in years)")+
  guides(fill=guide_legend(title=NULL))


ggplot(data=uspto_dpma_register_join,  aes(patent_year, y=day_difference)) + geom_line() 
ggplot(data=uspto_dpma_register_join,  aes(patent_year, stat="count")) + geom_histogram(binwidth = 1)
