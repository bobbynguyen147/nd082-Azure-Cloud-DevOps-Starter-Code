# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

**1- Clone this repository**
git clone https://github.com/bobbynguyen147/nd082-Azure-Cloud-DevOps-Starter-Code.git

**2- Create an Azure Policy**

Log into your Azure account

    az login 

The policy we will deploy will prevent any new resources from being created without the tag "Udacity".

To run this, use the bash script from `starter_files` directory:

    az policy definition create --name "tagging-policy" --display-name "Deny creation of resources without tags" --description "Not allowing any new resources from being created without tags"  --rules ./azure_policy/az_policies.json --mode All

If it works you should be able to view the assigned policy using:

    az policy assignment list

**3- Create a variables.json file and update the values provided by the above steps**

variables.json

{

"client_id": "",

"client_secret": "",

"subscription_id": "",

"tenant_id": "",

"resource_name": "",

"image_name": "",

"location": ""

}

**4- Deploy your packer image**
Run packer file

    packer build -var-file="variables.json" ./packer/server.json

**5- Deploy your infraustructure with Terraform**
cd terraform/
terraform init
terraform plan -out solution.plan
terraform apply -auto-approve


### Output
**Azure Policy Output**
You should see something like the screenshot `screenshots/create_policy_output.png`

**Terraform plan output**
After running the plan you should see like the screenshot `screenshots/terraform_plan_output.png`

**Terraform apply output**
After running apply you should see like the screenshot `screenshots/terraform_apply_output.png`

