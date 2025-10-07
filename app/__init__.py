from flask import Flask, jsonify
from app.routes.user_routes import user_blueprint
from app.routes.product_routes import product_blueprint
from prometheus_client import make_wsgi_app, Counter
from werkzeug.middleware.dispatcher import DispatcherMiddleware

def create_app():
    app = Flask(__name__)

    # Register blueprints
    app.register_blueprint(user_blueprint)
    app.register_blueprint(product_blueprint)

    @app.route('/')
    def home():
        return jsonify({"message": "Microservice is running"}), 200


    # Health check endpoint
    @app.route('/health')
    def health():
        return jsonify({"status": "ok"}), 200

    # Prometheus metrics setup
    REQUESTS = Counter('app_requests_total', 'Total HTTP requests')

    @app.before_request
    def before_request():
        REQUESTS.inc()

    # Mount /metrics endpoint
    app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
        '/metrics': make_wsgi_app()
    })

    return app
