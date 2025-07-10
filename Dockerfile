FROM --platform=linux/amd64 python:3.13-slim-bookworm AS build_amd64

ENV APP_NAME=scancode-toolkit
ENV APP_USER=app
ENV APP_DIR=/opt/$APP_NAME
ENV VENV_LOCATION=/opt/$APP_NAME/.venv

# Python settings: Force unbuffered stdout and stderr (i.e. they are flushed to terminal immediately)
ENV PYTHONUNBUFFERED=1
# Python settings: do not write pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# OS requirements as per
# https://scancode-toolkit.readthedocs.io/en/latest/getting-started/install.html
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
       bzip2 \
       xz-utils \
       zlib1g \
       libxml2-dev \
       libxslt1-dev \
       libgomp1 \
       libsqlite3-0 \
       libgcrypt20 \
       libpopt0 \
       libzstd1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create the APP_USER group and user
RUN addgroup --system $APP_USER \
 && adduser --system --group --home=$APP_DIR $APP_USER \
 && chown $APP_USER:$APP_USER $APP_DIR

# Setup the work directory and the user as APP_USER for the remaining stages
WORKDIR $APP_DIR
USER $APP_USER

# Create the virtualenv
RUN python -m venv $VENV_LOCATION
# Enable the virtualenv, similar effect as "source activate"
ENV PATH=$VENV_LOCATION/bin:$PATH

RUN pip install --no-cache-dir scancode-toolkit
RUN scancode-reindex-licenses

ENTRYPOINT ["scancode"]

