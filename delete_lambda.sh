find . -name '*.zip'| cut -d/ -f2- | cut -d . -f-1 > delete_function.txt
cat delete_function.txt
while read p; do
	echo "Delete Lambda Function: $p"
	aws lambda delete-function --function-name $p
done <delete_function.txt
rm -rf delete_function.txt
