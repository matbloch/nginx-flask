from flask import Flask, Blueprint
import logging

blueprint = Blueprint('index', __name__)
logger = logging.getLogger()

@blueprint.route('/', defaults={'path': ''})
@blueprint.route('/<path:path>')
def catch_all(path):
    logger.info(f'Called route: {path}')
    return f'Called API endpoint: {path}'


def configure_logging(debug=False):
    root = logging.getLogger()
    h = logging.StreamHandler()
    fmt = logging.Formatter(
        fmt='%(asctime)s %(levelname)s (%(name)s) %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S'
    )
    h.setFormatter(fmt)
    root.addHandler(h)
    root.setLevel(logging.DEBUG if debug else logging.INFO)


def init_extensions(app: Flask):
    pass


def create_app(config_object_name) -> Flask:
    """
    :param config_object_name: The python path of the config object.
                               E.g. appname.settings.ProdConfig
    """

    # Initialize the core application
    app = Flask(__name__, instance_relative_config=False)
    app.config.from_object(config_object_name)

    # Initialize Plugins at startup using init_app()
    init_extensions(app)

    with app.app_context():
        # Register Blueprints
        app.register_blueprint(blueprint, url_prefix='/')
        configure_logging(debug=True)
        return app
