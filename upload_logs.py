# example command: python3 upload_logs.py accessLogs.2023-04-18.tar.gz /tmp/accessLogs.2023-04-18.tar.gz

from minio import Minio
import os
import sys


MINIO_URL = os.environ.get('MINIO_URL')
BUCKET = os.environ.get('BUCKET')
ACCESS_KEY = os.environ.get('ACCESS_KEY')
SECRET_KEY = os.environ.get('SECRET_KEY')

if len(sys.argv) == 3:
    FILE_NAME = sys.argv[1]
    LOCAL_FILE_PATH = sys.argv[2]
    

    client = Minio(
        MINIO_URL,
        access_key=ACCESS_KEY,
        secret_key=SECRET_KEY
    )

    if client.bucket_exists(BUCKET) == False:
        client.make_bucket(BUCKET)

    client.fput_object(BUCKET, FILE_NAME, LOCAL_FILE_PATH)
else:
    print("Usage: Upload_logs.py <filename> <local file path>")
