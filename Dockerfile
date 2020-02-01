FROM python:3.8.1-slim-buster

COPY LICENSE README.md /

RUN apt-get update -y && apt-get install bash && pip install black

COPY entrypoint.sh /app/entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]

# CMD ["/bin/bash"]
