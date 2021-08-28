FROM public.ecr.aws/lambda/python:3.8

RUN pip3 install mysql-connector-python boto3 pandas

COPY index.py ${LAMBDA_TASK_ROOT}

CMD [ "index.handler" ]