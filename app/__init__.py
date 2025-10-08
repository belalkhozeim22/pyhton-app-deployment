from flask import Flask, jsonify, request, g
from app.routes.user_routes import user_blueprint
from app.routes.product_routes import product_blueprint
from prometheus_client import make_wsgi_app, Counter, Histogram
from werkzeug.middleware.dispatcher import DispatcherMiddleware
import time

def create_app():
    app = Flask(__name__)

    # Register blueprints
    app.register_blueprint(user_blueprint)
    app.register_blueprint(product_blueprint)

    @app.route('/')
    def home():
        return jsonify({"message": "Microservice is running"}), 200

    @app.route('/health')
    def health():
        return jsonify({"status": "ok"}), 200

    # Prometheus metrics
    REQUESTS = Counter('app_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
    LATENCY = Histogram('app_request_latency_seconds', 'Request latency', ['method', 'endpoint'])

    @app.before_request
    def before_request():
        g.start_time = time.time()
        REQUESTS.labels(method=request.method, endpoint=request.path).inc()

    @app.after_request
    def after_request(response):
        LATENCY.labels(method=request.method, endpoint=request.path).observe(time.time() - g.start_time)
        return response

    # Mount /metrics
    app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {'/metrics': make_wsgi_app()})

    return app
