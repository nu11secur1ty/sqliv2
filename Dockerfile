#FROM python:2-slim
FROM python:2

RUN apt update && apt install -y git

RUN git clone https://github.com/Hadesy2k/sqliv.git
WORKDIR /sqliv
RUN pip2 install -r requirements.txt && python setup.py -i

ENTRYPOINT ["python","sqliv.py"]
CMD ["--help"]
