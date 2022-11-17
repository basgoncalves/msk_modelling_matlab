from cProfile import label
from calendar import c
import csv
from sre_constants import RANGE
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from scipy.ndimage import zoom

plt.style.use('ggplot')

gcl2=r'Dados_Sidestep\ACL2\CUTLEFT1\Visual3d_SIMM_grf.csv'
cl2=r'Dados_Sidestep\ACL2\CUTLEFT1\IAA\results\cl2_InducedAccelerations_induced_constraint_reactions.csv'

def create_list(file_dir, variable):
    with open(file_dir) as csvfile:
        reader = csv.reader(csvfile, delimiter = ",")
        count=0
        iterator=0
        col=-1
        values=[]
        verified_label="none"
        for row in reader:
            if count==0:
                for label in row:
                    if label==variable:
                        col=iterator
                        verified_label=label
                        break
                    else:
                        iterator+=1

            if count>0 and col!=-1:
                values.append(float(row[col]))
            count+=1
        return values

test_list=create_list(gcl2,"l_ground_force_vx")
test_list2=create_list(cl2,"total_left_foot_contact_ground_Fx")

time_g=create_list(gcl2,"time")
time_c=create_list(cl2,"time")

def interval(list):
    new_list=[]
    for x in range(len(list)):
        if (x!=0 and x!=len(list)-1):
            if (list[x]!=0 or list[x+1]!=0 or list[x-1]!=0 ):
                new_list.append(list[x])
    return new_list

# test_result_list=interval(test_list)

plt.suptitle("Test")
plt.subplot(4,2,1)
plt.plot(test_list)

plt.subplot(4,2,2)
plt.plot(test_list2)

plt.subplot(4,2,3)
test_list3=interval(test_list)
plt.plot(test_list3)

plt.subplot(4,2,4)
test_list6=interval(test_list2)
plt.plot(test_list6)

plt.subplot(4,2,5)
factor=250/len(test_list3)
test_list4=zoom(test_list3,factor)
plt.plot(test_list4)

plt.subplot(4,2,6)
factor=250/len(test_list6)
test_list5=zoom(test_list6,factor)
plt.plot(test_list5)

plt.subplot(4,2,7)
plt.plot(time_g,test_list,label="grf")
plt.plot(time_c,test_list2,label="crf")
plt.legend()

plt.subplot(4,2,8)
plt.plot(test_list5,label="grf")
plt.plot(test_list4,label="crf")
plt.legend()
plt.show()



