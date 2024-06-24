cd /home/ubuntu/ &&
rm -rf SCA_Devops_Python_Project_Terraform
git clone https://github.com/maryjonah/SCA_Devops_Python_Terraform.git
cd SCA_Devops_Python_Terraform
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd src/
flask run --host=0.0.0.0