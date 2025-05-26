FROM python:3.11.2-slim-buster AS builder


RUN mkdir /code
WORKDIR /code

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


COPY requirements.txt /code/

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt



#second stage

FROM python:3.11.2-slim-buster


RUN useradd -m -r appuser && mkdir /code && chown -R appuser /code

WORKDIR /code

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin


COPY --chown=appuser:appuser . /code/

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser


EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "manage.wsgi:application", "--workers", "3"]