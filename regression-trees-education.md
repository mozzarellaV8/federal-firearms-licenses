# Significant Regression Tree Outputs

# Educational Attainment

Regression trees grown on Educational Attainment data - no gender split, total HS and College graduate figures only.

![rpart model 02 - edu](vis/eda-education/rpart-model-02.png)

```{R}
summary(edu.rpart02)
Call:
rpart(formula = perCapitaFFL ~ ., data = edu.tree.all)
  n= 50 

          CP nsplit rel error    xerror      xstd
1 0.35194566      0 1.0000000 1.0265601 0.3407867
2 0.07446463      1 0.6480543 0.7881678 0.1834121
3 0.02353785      2 0.5735897 0.7607683 0.1880435
4 0.01000000      3 0.5500519 0.7710744 0.1911237
```

```{R}
Variable importance
per.capita.18to24.BA 35
per.capita.25to34.BA 26
per.capita.35to44.BA 17
per.capita.45to64.BA 14
per.capita.25to34.HS 4
per.capita.35to44.HS 3
per.capita.45to64.HS 1
```
 
```{R}
Node number 1: 50 observations,    complexity param=0.3519457
  mean=31.16886, MSE=457.3193 
  left son=2 (41 obs) right son=3 (9 obs)
  Primary splits:
      per.capita.18to24.BA < 716.5771 to the right, improve=0.3519457, (0 missing)
      per.capita.18to24.HS < 3235.519 to the left,  improve=0.2238889, (0 missing)
      per.capita.25to34.BA < 4765.145 to the right, improve=0.1950904, (0 missing)
      per.capita.35to44.BA < 4302.184 to the right, improve=0.1693613, (0 missing)
      per.capita.45to64.BA < 7812.475 to the right, improve=0.1678096, (0 missing)
  Surrogate splits:
      per.capita.25to34.BA < 3306.652 to the right, agree=0.94, adj=0.667, (0 split)
      per.capita.35to44.BA < 3111.323 to the right, agree=0.90, adj=0.444, (0 split)
      per.capita.45to64.BA < 5490.893 to the right, agree=0.88, adj=0.333, (0 split)

Node number 2: 41 observations,    complexity param=0.07446463
  mean=25.22488, MSE=169.8338 
  left son=4 (15 obs) right son=5 (26 obs)
  Primary splits:
      per.capita.25to34.BA < 4765.145 to the right, improve=0.2445297, (0 missing)
      per.capita.45to64.BA < 7345.389 to the right, improve=0.1922020, (0 missing)
      per.capita.35to44.HS < 11084.91 to the right, improve=0.1684576, (0 missing)
      per.capita.35to44.BA < 4847.95  to the right, improve=0.1626558, (0 missing)
      per.capita.65plus.BA < 3845.8   to the right, improve=0.1573253, (0 missing)
  Surrogate splits:
      per.capita.25to34.HS < 12585.22 to the right, agree=0.878, adj=0.667, (0 split)
      per.capita.35to44.BA < 4576.164 to the right, agree=0.854, adj=0.600, (0 split)
      per.capita.18to24.BA < 969.5534 to the right, agree=0.829, adj=0.533, (0 split)
      per.capita.45to64.BA < 7769.831 to the right, agree=0.829, adj=0.533, (0 split)
      per.capita.35to44.HS < 11331    to the right, agree=0.756, adj=0.333, (0 split)

Node number 3: 9 observations
  mean=58.24696, MSE=872.8001 

Node number 4: 15 observations
  mean=16.74053, MSE=159.0928 

Node number 5: 26 observations,    complexity param=0.02353785
  mean=30.11971, MSE=110.5419 
  left son=10 (19 obs) right son=11 (7 obs)
  Primary splits:
      per.capita.18to24.BA < 966.096  to the left,  improve=0.1872648, (0 missing)
      per.capita.25to34.HS < 11881.74 to the left,  improve=0.1656467, (0 missing)
      per.capita.45to64.HS < 23703.53 to the left,  improve=0.1367472, (0 missing)
      per.capita.35to44.HS < 10780.12 to the right, improve=0.1128560, (0 missing)
      per.capita.65plus.HS < 12351.7  to the left,  improve=0.1105765, (0 missing)
  Surrogate splits:
      per.capita.45to64.BA < 8451.826 to the left,  agree=0.846, adj=0.429, (0 split)
      per.capita.35to44.HS < 10628.44 to the right, agree=0.808, adj=0.286, (0 split)
      per.capita.45to64.HS < 24021.96 to the left,  agree=0.808, adj=0.286, (0 split)
      per.capita.25to34.HS < 11123.49 to the right, agree=0.769, adj=0.143, (0 split)
      per.capita.65plus.HS < 13362.84 to the left,  agree=0.769, adj=0.143, (0 split)

Node number 10: 19 observations
  mean=27.35809, MSE=50.18995 

Node number 11: 7 observations
  mean=37.61553, MSE=197.4662 
```