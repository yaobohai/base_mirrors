FROM python:3.7

RUN mkdir /app/
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn requests

ADD consul_deregister.py /app/

CMD ["python3", "/app/consul_deregister.py"]