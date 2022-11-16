import subprocess
import sys
import pkg_resources

# create virtual environment and add the needed packages
# python -m venv \path\to\new_virtual_environment
# cd .\virtual_env\Scripts\activate
# .\install_needed_pkg.py
# .\virtual_env\Scripts\python.exe

Packages = ["python-docx","docx","numpy","requests","bs4",
"pandas","selenium","webdriver-manager","matplotlib","jupyter"]

installed_packages = pkg_resources.working_set
installed_packages_list = sorted(["%s==%s" % (i.key, i.version) for i in installed_packages])


for pkg in Packages:
    if any(pkg in s for s in installed_packages_list):
        print(pkg + " already installed")
    else:
        subprocess.check_call([sys.executable, "-m", "pip", "install", pkg])
