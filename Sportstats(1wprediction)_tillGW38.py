# -*- coding: utf-8 -*-
"""
Created on Tue Apr 11 23:10:52 2017

@author: jozh
"""


import numpy as np
import pandas as pd
from sklearn import linear_model
from pandas import ExcelWriter
from sklearn.ensemble import RandomForestClassifier

data = pd.read_csv('test_20170609.csv')

df1 = data.fillna(value = 0)
df1['hometeam_form'] = (df1['hometeam_homepts_form'] + df1['hometeam_awaypts_form']) / \
    (df1['hometeam_homematches_form'] + df1['hometeam_awaymatches_form'])
df1['awayteam_form'] = (df1['awayteam_homepts_form'] + df1['awayteam_awaypts_form']) / \
    (df1['awayteam_homematches_form'] + df1['awayteam_awaymatches_form'])
df1['hometeam_goal_form'] = (df1['hometeam_homeGoalAg_form'] + df1['hometeam_awayGoalAg_form']) / \
    (df1['hometeam_homematches_form'] + df1['hometeam_awaymatches_form'])
df1['awayteam_goal_form'] = (df1['awayteam_homeGoalAg_form'] + df1['awayteam_awayGoalAg_form']) / \
    (df1['awayteam_homematches_form'] + df1['awayteam_awaymatches_form'])    
df1['hometeam_goalc_form'] = (df1['hometeam_homeGoalCon_form'] + df1['hometeam_awayGoalCon_form']) / \
    (df1['hometeam_homematches_form'] + df1['hometeam_awaymatches_form'])
df1['awayteam_goalc_form'] = (df1['awayteam_homeGoalCon_form'] + df1['awayteam_awayGoalCon_form']) / \
    (df1['awayteam_homematches_form'] + df1['awayteam_awaymatches_form'])     

df1['hometeam_form1'] = (df1['hometeam_homepts_form1'] + df1['hometeam_awaypts_form1']) / \
    (df1['hometeam_homematches_form1'] + df1['hometeam_awaymatches_form1'])
df1['awayteam_form1'] = (df1['awayteam_homepts_form1'] + df1['awayteam_awaypts_form1']) / \
    (df1['awayteam_homematches_form1'] + df1['awayteam_awaymatches_form1'])
df1['hometeam_goal_form1'] = (df1['hometeam_homeGoalAg_form1'] + df1['hometeam_awayGoalAg_form1']) / \
    (df1['hometeam_homematches_form1'] + df1['hometeam_awaymatches_form1'])
df1['awayteam_goal_form1'] = (df1['awayteam_homeGoalAg_form1'] + df1['awayteam_awayGoalAg_form1']) / \
    (df1['awayteam_homematches_form1'] + df1['awayteam_awaymatches_form1'])    
df1['hometeam_goalc_form1'] = (df1['hometeam_homeGoalCon_form1'] + df1['hometeam_awayGoalCon_form1']) / \
    (df1['hometeam_homematches_form1'] + df1['hometeam_awaymatches_form1'])
df1['awayteam_goalc_form1'] = (df1['awayteam_homeGoalCon_form1'] + df1['awayteam_awayGoalCon_form1']) / \
    (df1['awayteam_homematches_form1'] + df1['awayteam_awaymatches_form1'])     
    
df1['hometeam_bigchance_pm_c']  =  (df1['hometeam_homebigchance_pm_c'] + df1['hometeam_awaybigchance_pm_c']) / \
    (df1['hometeam_homematches_c'] + df1['hometeam_awaymatches_c'])
df1['hometeam_touchinbox_pm_c']  =  (df1['hometeam_hometouchinbox_pm_c'] + df1['hometeam_awaytouchinbox_pm_c']) / \
    (df1['hometeam_homematches_c'] + df1['hometeam_awaymatches_c'])
df1['hometeam_SoT_pm_c']  =  (df1['hometeam_homeSoT_pm_c'] + df1['hometeam_awaySoT_pm_c']) / \
    (df1['hometeam_homematches_c'] + df1['hometeam_awaymatches_c'])
df1['awayteam_bigchance_pm_c']  =  (df1['awayteam_homebigchance_pm_c'] + df1['awayteam_awaybigchance_pm_c']) / \
    (df1['awayteam_homematches_c'] + df1['awayteam_awaymatches_c'])
df1['awayteam_touchinbox_pm_c']  =  (df1['awayteam_hometouchinbox_pm_c'] + df1['awayteam_awaytouchinbox_pm_c']) / \
    (df1['awayteam_homematches_c'] + df1['awayteam_awaymatches_c'])
df1['awayteam_SoT_pm_c']  =  (df1['awayteam_homeSoT_pm_c'] + df1['awayteam_awaySoT_pm_c']) / \
    (df1['awayteam_homematches_c'] + df1['awayteam_awaymatches_c'])    
df1['hometeam_oppo_str']  =  (df1['hometeam_homeoppo_awaypts'] + df1['hometeam_awayoppo_homepts']) / \
    (df1['hometeam_homeoppo_match'] + df1['hometeam_awayoppo_match'])      
df1['awayteam_oppo_str']  =  (df1['awayteam_homeoppo_awaypts'] + df1['awayteam_awayoppo_homepts']) / \
    (df1['awayteam_homeoppo_match'] + df1['awayteam_awayoppo_match'])      
#to add awayteam_form here

df_final = df1

X0 = df_final.loc[(df_final["gameweek"] > 6) & (df_final["gameweek"] < 29)]
X = X0.drop([u'gameweek', u'calendardate', u'hometeam', u'awayteam', u'homepts', u'FTHG', u'FTAG',\
     u'awaypts', u'ftr', u'B365H', u'B365D', u'B365A', u'hometeam_matches', u'awayteam_matches',\
     u'hometeam_homepts_form', u'hometeam_awaypts_form', u'hometeam_homematches_form',\
     u'hometeam_awaymatches_form', u'awayteam_homepts_form', u'awayteam_awaypts_form', \
     u'awayteam_homematches_form', u'awayteam_awaymatches_form', 
     u'hometeam_homeGoalAg_form', u'hometeam_awayGoalAg_form', u'awayteam_homeGoalAg_form',\
     u'awayteam_awayGoalAg_form', u'hometeam_homeGoalCon_form', u'hometeam_awayGoalCon_form',\
     u'awayteam_homeGoalCon_form', u'awayteam_awayGoalCon_form',
     u'hometeam_homepts_form1', u'hometeam_awaypts_form1', u'hometeam_homematches_form1',\
     u'hometeam_awaymatches_form1', u'awayteam_homepts_form1', u'awayteam_awaypts_form1', \
     u'awayteam_homematches_form1', u'awayteam_awaymatches_form1', 
     u'hometeam_homeGoalAg_form1', u'hometeam_awayGoalAg_form1', u'awayteam_homeGoalAg_form1',\
     u'awayteam_awayGoalAg_form1', u'hometeam_homeGoalCon_form1', u'hometeam_awayGoalCon_form1',\
     u'awayteam_homeGoalCon_form1', u'awayteam_awayGoalCon_form1',   
       u'hometeam_homematches_c', u'hometeam_homebigchance_pm_c',
       u'hometeam_hometouchinbox_pm_c', u'hometeam_homeSoT_pm_c', 
       u'hometeam_awaymatches_c', u'hometeam_awaybigchance_pm_c',
       u'hometeam_awaytouchinbox_pm_c', u'hometeam_awaySoT_pm_c',
       u'awayteam_homematches_c', u'awayteam_homebigchance_pm_c',
       u'awayteam_hometouchinbox_pm_c', u'awayteam_homeSoT_pm_c',
       u'awayteam_awaymatches_c', u'awayteam_awaybigchance_pm_c',
       u'awayteam_awaytouchinbox_pm_c', u'awayteam_awaySoT_pm_c', u'hometeam_homeoppo_awaypts',
       u'hometeam_awayoppo_homepts', u'hometeam_homeoppo_match', u'hometeam_awayoppo_match', 
       u'awayteam_homeoppo_awaypts', u'awayteam_awayoppo_homepts', u'awayteam_homeoppo_match', 
       u'awayteam_awayoppo_match'], axis=1) 
y = X0['ftr']

clf = RandomForestClassifier(n_estimators = 100)
clf.fit(X, y)
clf.score(X, y)
feat_labels = X.columns
importances = clf.feature_importances_
indices = np.argsort(importances)[::-1]
for f in range(X.shape[1]):
    print("%2d) %-*s %f" % (f + 1, 30,
    feat_labels[indices[f]],
    importances[indices[f]]))

#feature selection threshold - deprecated
X.shape    
X_selected = clf.transform(X, threshold=0.02)
X_selected.shape 

#SelectModel method
from sklearn.svm import LinearSVC
from sklearn.feature_selection import SelectFromModel

X.shape
lsvc = LinearSVC(C=0.1, penalty="l1", dual=False).fit(X, y)
model = SelectFromModel(lsvc, prefit=True)
X_new = model.transform(X)
X_new.shape

   

yhat = clf.predict_proba(X)  #which is which?
clf.classes_
yhat.shape
X.shape

yhat[:,0].shape

X0['yhats_A'] = yhat[:,0]
X0['yhats_D'] = yhat[:,1]
X0['yhats_H'] = yhat[:,2]


writer = ExcelWriter('output.xlsx')
X0.to_excel(writer,'Sheet1')
writer.save()

X_test0 = df_final.loc[(df_final["gameweek"] >= 28)]
X_test = X_test0.drop([u'gameweek', u'calendardate', u'hometeam', u'awayteam', u'homepts', u'FTHG', u'FTAG',\
     u'awaypts', u'ftr', u'B365H', u'B365D', u'B365A', u'hometeam_matches', u'awayteam_matches',\
     u'hometeam_homepts_form', u'hometeam_awaypts_form', u'hometeam_homematches_form',\
     u'hometeam_awaymatches_form', u'awayteam_homepts_form', u'awayteam_awaypts_form', \
     u'awayteam_homematches_form', u'awayteam_awaymatches_form', 
     u'hometeam_homeGoalAg_form', u'hometeam_awayGoalAg_form', u'awayteam_homeGoalAg_form',\
     u'awayteam_awayGoalAg_form', u'hometeam_homeGoalCon_form', u'hometeam_awayGoalCon_form',\
     u'awayteam_homeGoalCon_form', u'awayteam_awayGoalCon_form',
     u'hometeam_homepts_form1', u'hometeam_awaypts_form1', u'hometeam_homematches_form1',\
     u'hometeam_awaymatches_form1', u'awayteam_homepts_form1', u'awayteam_awaypts_form1', \
     u'awayteam_homematches_form1', u'awayteam_awaymatches_form1', 
     u'hometeam_homeGoalAg_form1', u'hometeam_awayGoalAg_form1', u'awayteam_homeGoalAg_form1',\
     u'awayteam_awayGoalAg_form1', u'hometeam_homeGoalCon_form1', u'hometeam_awayGoalCon_form1',\
     u'awayteam_homeGoalCon_form1', u'awayteam_awayGoalCon_form1',   
       u'hometeam_homematches_c', u'hometeam_homebigchance_pm_c',
       u'hometeam_hometouchinbox_pm_c', u'hometeam_homeSoT_pm_c', 
       u'hometeam_awaymatches_c', u'hometeam_awaybigchance_pm_c',
       u'hometeam_awaytouchinbox_pm_c', u'hometeam_awaySoT_pm_c',
       u'awayteam_homematches_c', u'awayteam_homebigchance_pm_c',
       u'awayteam_hometouchinbox_pm_c', u'awayteam_homeSoT_pm_c',
       u'awayteam_awaymatches_c', u'awayteam_awaybigchance_pm_c',
       u'awayteam_awaytouchinbox_pm_c', u'awayteam_awaySoT_pm_c', u'hometeam_homeoppo_awaypts',
       u'hometeam_awayoppo_homepts', u'hometeam_homeoppo_match', u'hometeam_awayoppo_match', 
       u'awayteam_homeoppo_awaypts', u'awayteam_awayoppo_homepts', u'awayteam_homeoppo_match', 
       u'awayteam_awayoppo_match'], axis=1) 
y_test = X_test0['ftr']       
       
clf.score(X_test, y_test)

yhat_test = clf.predict_proba(X_test)

X_test0['yhats_A'] = yhat_test[:,0]
X_test0['yhats_D'] = yhat_test[:,1]
X_test0['yhats_H'] = yhat_test[:,2]

writer = ExcelWriter('output1.xlsx')
X_test0.to_excel(writer,'Sheet1')
writer.save()





from sklearn.linear_model import LogisticRegression
from sklearn import cross_validation
from sklearn.naive_bayes import GaussianNB
from sklearn import tree
from sklearn.ensemble import (RandomForestClassifier, GradientBoostingClassifier, AdaBoostClassifier,
VotingClassifier)
from sklearn import svm
import datetime 
estimators = {}
estimators['logisticregression'] = LogisticRegression()
estimators['bayes'] = GaussianNB()
estimators['tree'] = tree.DecisionTreeClassifier()
estimators['forest_100'] = RandomForestClassifier(n_estimators = 100)
estimators['forest_10'] = RandomForestClassifier(n_estimators = 10)
estimators['svm_c_rbf'] = svm.SVC()
estimators['svm_c_linear'] = svm.SVC(kernel='linear')
estimators['svm_linear'] = svm.LinearSVC()
estimators['gbc'] = GradientBoostingClassifier(learning_rate=0.1)
estimators['abc'] = AdaBoostClassifier()


for k in estimators.keys():
    start_time = datetime.datetime.now()
    print '----%s----' % k
    estimators[k] = estimators[k].fit(X, y)
    pred = estimators[k].predict(X_test)
    print("%s Score: %0.02f" % (k, estimators[k].score(X_test, y_test)))
    scores = cross_validation.cross_val_score(estimators[k], X, y, cv=5)
    print("%s Cross Avg. Score: %0.02f (+/- %0.02f)" % (k, scores.mean(), scores.std() * 2))
    end_time = datetime.datetime.now()
    time_spend = end_time - start_time
    print("%s Time: %0.02f" % (k, time_spend.total_seconds()))
    
#from sklearn.grid_search import GridSearchCV
#for k in estimators.keys():
#    start_time = datetime.datetime.now()
#    print '----%s----' % k
#    tuned_parameters = [{'kernel': ['rbf'], 'gamma': [1e-3, 1e-4],
#                     'C': [1, 10, 100, 1000]},
#                    {'kernel': ['linear'], 'C': [1, 10, 100, 1000]}]
#    estimators[k] = GridSearchCV(estimator=estimators[k],
#                                param_grid=param_grid,
#                                scoring='accuracy',
#                                cv=10,
#                                n_jobs=-1)
#    pred = estimators[k].predict(X_test)
#    print("%s Score: %0.02f" % (k, estimators[k].score(X_test, y_test)))
#    scores = cross_validation.cross_val_score(estimators[k], X, y, cv=5)
#    print("%s Cross Avg. Score: %0.02f (+/- %0.02f)" % (k, scores.mean(), scores.std() * 2))
#    end_time = datetime.datetime.now()
#    time_spend = end_time - start_time
#    print("%s Time: %0.02f" % (k, time_spend.total_seconds()))    
    
    
    
from sklearn.feature_selection import RFE
rfe = RFE(clf, 41)
clf1 = rfe.fit(X, y)
clf1.score(X, y)

yhat_test = clf1.predict_proba(X_test)
clf1.score(X_test, y_test)
#conduct grid search for the models:
#logistic regression
from sklearn.grid_search import GridSearchCV
param_range = [0.0001, 0.001, 0.01, 0.1, 1.0, 10.0, 100.0, 1000.0]        
tuned_parameters = [{'C': param_range}]

scores = ['precision', 'recall']

for score in scores:
    print("# Tuning hyper-parameters for %s" % score)
    print()

    clf = GridSearchCV(LogisticRegression(), tuned_parameters, cv=5,
                       scoring='%s_macro' % score)
    clf.fit(X, y)   
    print(clf.best_params_)     
    y_true, y_pred = y_test, clf.predict(X_test)
    #from sklearn.metrics import classification_report
    #print(classification_report(y_true, y_pred))
    print(clf.score(X_test, y_test))


#lr: c=0.01;             
tuned_parameters = [{'max_features': [0.1, 0.2, 0.3, 0.4, 0.5]}]            

scores = ['precision', 'recall']

for score in scores:
    print("# Tuning hyper-parameters for %s" % score)
    print()

    clf = GridSearchCV(RandomForestClassifier(n_estimators = 100), tuned_parameters, cv=5,
                       scoring='%s_macro' % score)
    clf.fit(X, y)   
    print(clf.best_params_)     
    print(clf.score(X_test, y_test))
#rf: max_feature=0.4;   

from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
#clf1 = LogisticRegression()
pipe1 = Pipeline([['sc', StandardScaler()], ['clf', LogisticRegression()]])
clf2 = GaussianNB()
clf3 = RandomForestClassifier(n_estimators = 100)
clf4 = GradientBoostingClassifier()
clf5 = AdaBoostClassifier()
eclf = VotingClassifier(estimators=[('lr', pipe1), ('bayes', clf2), ('rf', clf3)], voting='soft', weights=[1,1,2])
scores = cross_validation.cross_val_score(eclf, X, y, cv=5, scoring='accuracy') # it's the nested score here
print("Cross Avg. Score: %s (+/- %s)" % (scores.mean(), scores.std() * 2))
#auc = cross_validation.cross_val_score(eclf, X, y, cv=5, scoring='roc_auc')
#print("Cross Avg. Score: %s (+/- %s)" % (auc.mean(), auc.std() * 2))
eclf.fit(X,y)
#(eclf.score(X,y))
print(eclf.score(X_test, y_test))


yhat = eclf.predict_proba(X)  

X0['yhats_A'] = yhat[:,0]
X0['yhats_D'] = yhat[:,1]
X0['yhats_H'] = yhat[:,2]


writer = ExcelWriter('output.xlsx')
X0.to_excel(writer,'Sheet1')
writer.save()

yhat_test = eclf.predict_proba(X_test)

X_test0['yhats_A'] = yhat_test[:,0]
X_test0['yhats_D'] = yhat_test[:,1]
X_test0['yhats_H'] = yhat_test[:,2]

writer = ExcelWriter('output1.xlsx')
X_test0.to_excel(writer,'Sheet1')
writer.save()