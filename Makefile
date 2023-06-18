.PHONY: init plan apply destroy deploy

init:
	terraform init

plan:
	terraform plan -out=tfplan.out

apply:
	terraform apply -input=false tfplan.out

destroy:
	terraform destroy
	
deploy: init plan apply