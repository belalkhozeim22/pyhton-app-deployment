FROM python:3.11-slim
RUN useradd --create-home appuser
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PYTHONPATH=/app

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 5000
CMD ["python", "main.py"]
