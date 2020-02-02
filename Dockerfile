FROM python:3.8.1-slim-buster

LABEL maintainer="jafow <jared.a.fowler@gmail.com>"
LABEL "com.github.actions.name"="python-format-pr"
LABEL "com.github.actions.description"="Format python files in a pull request"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="green"

ENV HUB_VERSION "2.14.1"

COPY LICENSE README.md /

RUN apt-get update && apt-get install -y bash curl git jq \
    && curl -sSL https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz | tar -xzpf - \
    && mv hub-linux-amd64-$HUB_VERSION/bin/hub /bin \
    && rm -Rf hub-linux-amd64-$HUB_VERSION \
    && pip install black

COPY entrypoint.sh /entrypoint.sh

RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
