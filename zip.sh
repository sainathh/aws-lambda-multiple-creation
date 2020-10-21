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

#zip -r dir1.zip ./dir1/*
