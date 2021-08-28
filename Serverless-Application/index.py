import os
import sys
import mysql.connector
import boto3
import pandas
import urllib.parse

# User object will be parsed from csv and write to the database
class User(object):
    Id = ""
    Username = ""
    Firstname = ""
    Lastname = ""
# Create initial database if does not exist
def create_database(conn):
    print ("creating database if not exist...")
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS Users(
    Id INTEGER NOT NULL PRIMARY KEY,
    Username TEXT NOT NULL,
    Firstname TEXT  NOT NULL,
    Lastname TEXT NOT NULL
    );
    """
    )
# read csv file from s3 bucket.Pparameter "key" is last uploaded file name of s3 bucket.
def read_from_s3(key):
    print ("retrieving data from s3 object storage...")
    # get ready for connecting s3
    client = boto3.client(
    's3',
    aws_access_key_id = os.environ.get("S3_KEY_ID"),
    aws_secret_access_key = os.environ.get("S3_ACCESS_KEY"),
    region_name = os.environ.get("S3_REGION_NAME")
    )
    # get file from s3
    obj = client.get_object(
        Bucket = os.environ.get("S3_BUCKET_NAME"),
        #Key = os.environ.get("S3_BUCKET_FILE_NAME")
        Key = key
    )
    # read file's body from csv
    data = pandas.read_csv(obj['Body'], delimiter=',')
    print ("data received...")
    # assign csv objects to the user objects
    list_of_rows = [list(row) for row in data.values]
    users = []
    for row in list_of_rows:
            user = {}
            user["Id"] = row[0]
            user["Username"] = row[1]
            user["Firstname"] = row[2]
            user["Lastname"]= row[3]
            users.append(user)
    return users  
# write parsed users to database.conn is database connection and users parameter is user obect that will be writed to the database
def write_to_database(users,conn):
    print ("writing users to the database...")
    for user in users:
        cur = conn.cursor()
        sql = "INSERT INTO Users (Id, Username , Firstname , Lastname) VALUES (%s, %s , %s , %s)"
        val = (user["Id"],user["Username"],user["Firstname"],user["Lastname"])
        cur.execute(sql, val)
        conn.commit()
    print ("users inserted...")
# handler for aws lambda function
def handler(event, context):
    try:
        print ("connecting to database...")
        conn = mysql.connector.connect(
        user=os.environ.get("MARIADB_USER"),
        password=os.environ.get("MARIADB_PASSWORD"),
        host=os.environ.get("MARIADB_HOST"),
        port=3306,
        database=os.environ.get("MARIADB_DATABASE")
        )
    except mysql.connector.Error as e:
        print(f"Error connecting to Mysql Database: {e}")
        sys.exit(1)
    create_database(conn)
    #get last uploaded file name from S3
    s3_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    #parse the objects and write to the db
    write_to_database(read_from_s3(s3_key),conn)
    conn.close()
    print ("IT IS OK!")