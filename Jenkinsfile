pipeline {
	agent any
	environment {
		AWS_ACCESS_KEY_ID     = credentials('access_key')
		AWS_SECRET_ACCESS_KEY = credentials('secret_key')
		REGION                = "us-east-2"
	}
	stages {
		stage('Clone') {
			steps {
				git 'https://github.com/karthikarige/aws-lambda-python.git'
			}
		}
		stage('Zip Lambda Function') {
		    steps {
		        sh '''
		           find ./ -name lambda_function.py | rev | cut -d/ -f2- | rev > output.txt
		           echo "Zip Lambda File Location!"
                   WORK_DIR=`pwd`
                   echo $WORK_DIR
                   while read p; do
                     echo "Zip File Path: $p"
                     export v=`echo "$p" | awk -F/ '{print $NF}'`
                     echo "Zip File Name: $v"
                     echo "Checkout to Lambda Path: $p"
                     cd $p
                     pwd
                     zip -r "$v.zip"  ./*
                     mv $v.zip $WORK_DIR
                     echo "Checking Out to Root Directory"
                     cd $WORK_DIR
                    done <output.txt
                '''
		    }
		}
		stage('Deploy to AWS') {
		    steps{
		        sh '''
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
                            if [[ `aws lambda get-alias --function-name $p --name $alias | wc -l` == 0 ]]
                                then
                                        echo "Alias Not Found Creating Alias with name: $alias"
                                        aws lambda create-alias --function-name $p \
                                         --name $alias --function-version $version
                                else
                                        echo "Alias found of name: $alias"
                                        echo "Updating Alias of $1 with version $version"
                                        aws lambda update-alias --function-name $p --name $alias --function-version $version
                                fi
                        else
                            echo "No Lambda Available"
                            echo " Create Lambda: $p"
                            aws lambda create-function --function-name $p --zip-file fileb://$p.zip \
                            --handler lambda_function.lambda_handler --runtime python3.8 \
                            --role arn:aws:iam::075314516853:role/service-role/csv_s3-role-zixb8gjl
                        fi
                    done <function.txt
		        '''
		    }
		}
	}
}
