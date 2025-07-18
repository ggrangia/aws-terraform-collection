FROM public.ecr.aws/lambda/python:3.12

COPY index.py requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install -r requirements.txt

CMD ["index.handler"]
