find . -name '*.zip'| cut -d/ -f2- | cut -d . -f-1 > function.txt
echo function.txt
REGION="us-east-2"
while read p; do
	echo "Function Name: $p"
	lambda=`aws lambda list-functions  --query 'Functions[].FunctionName' | grep $p | wc -l`
	echo $lambda
	if [[ `aws lambda list-functions  --query 'Functions[].FunctionName' | grep $p | wc -l` -ne 0 ]]
	then
		echo "Lambda Available"
		echo "Publish Lambda Version"
		version=`aws lambda publish-version --function-name $p --query "Version" | xargs`
		echo "Version to Create Alias:`aws lambda publish-version --function-name $p --query "Version" | xargs`"
		if [[ `aws lambda get-alias --function-name $p --name $1 | wc -l` == 0 ]]
		then
			echo "Alias Not Found Creating Alias with name: $1"
			aws lambda create-alias --function-name $p \
			 --name $1 --function-version $version 
		else
			echo "Alias found of name: $1"
			echo "Updating Alias of $1 with version $version"
			aws lambda update-alias --function-name $p --name $1 --function-version $version
		fi
	else
		echo "No Lambda Available"
		echo " Create Lambda: $p"
		aws lambda create-function --function-name $p --zip-file fileb://$p.zip	\
		--handler lambda_function.lambda_handler --runtime python3.8 \
		--role arn:aws:iam::075314516853:role/service-role/csv_s3-role-zixb8gjl
		version=`aws lambda publish-version --function-name $p --query "Version" | xargs`
		echo "Create Alias"
		aws lambda create-alias --function-name $p \
                 --name $1 --function-version $version
	fi
done <function.txt
