# create virtual environment and add the needed packages
# python -m venv .\virtual_env
# cd .\Python_environments\virtual_env\Scripts\  
# .\activate
# data_science_installpkg.py

import subprocess
import sys
import pkg_resources

def opensim():
    Packages = ['spicy','numpy','requests','bs4','pandas','selenium',
    'webdriver-manager','matplotlib','matplotlib_inline','autopep8','tk','jupyter','scipy']
    installed_packages = pkg_resources.working_set
    installed_packages_list = sorted(['%s==%s' % (i.key, i.version) for i in installed_packages])

    for pkg in Packages:
        try:
            __import__(pkg)
            print(pkg + 'is already installed')
        except:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', pkg])
            

opensim()