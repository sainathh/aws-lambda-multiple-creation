import boto3
import psycopg2
s3_client = boto3.client("s3")
s3 = boto3.resource('s3')

def lambda_handler(event,context):
	conn_string = "dbname='postgres' port='5432' user='karthik' password='' host=''"
	conn = psycopg2.connect(conn_string)
	conn.commit()
	
	bucket_name = event['Records'][0]['s3']['bucket']['name']
	s3_file = event['Records'][0]['s3']['object']['key']
	s3_file_name = s3_file.split("/")
	print(s3_file_name)
	resp = s3_client.get_object(Bucket=bucket_name,Key=s3_file)
	data = resp['Body'].read().decode("utf-8")
	print(data)
	employees = data.split("\n")
	print(employees)
	fileName = s3_file_name[1].split("-")
	timestamp = fileName[1].split(".")
	print(fileName[0])
	print(timestamp[0])
	for emp in employees:
		emp = emp.split(",")
		# put data into rds
		try:
			cursor = conn.cursor()
			#cursor.execute('INSERT INTO employees  VALUES ("'+str(emp[0])+'")')
			cursor.execute('INSERT INTO employees (user_id, username, location, filename, timestamp) VALUES (%s, %s, %s, %s, %s)', (emp[0], emp[1], emp[2], fileName[0], timestamp[0]))
			conn.commit()
			cursor.close()
		except Exception as e:
			print(e)
		
	    