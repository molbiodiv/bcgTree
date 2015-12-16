#!/usr/bin/python

import sys
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import pandas
from matplotlib.ticker import MultipleLocator, FormatStrFormatter

plt.clf()
fig=plt.figure(figsize=(40, 40))
ax = fig.add_subplot(111)
mat=pandas.read_csv(sys.argv[1],header=0,index_col=0)
# min=0 and max=1 is set to just distinguish absent and present
# remove those parameters to see colors scaled by value
ax.matshow(mat,cmap=cm.gray, interpolation='nearest', vmin=0, vmax=1)
locator=MultipleLocator(1)
locator.MAXTICKS = 10000
ax.xaxis.set_major_locator(locator)
ax.set_xticklabels([""]+mat.columns.tolist(), rotation=90)
ax.yaxis.set_major_locator(MultipleLocator(1))
ax.yaxis.set_major_formatter(FormatStrFormatter('%s'))
ax.set_yticklabels([""]+mat.index.tolist())
ax.tick_params(axis='both', which='both', labelsize=8, direction='out',
                       labelleft='on', labelright='off', labelbottom='off',
                       labeltop='on', left='on', right='off', bottom='off',
                       top='on')
plt.savefig(sys.argv[2], bbox_inches='tight', dpi = 100)

