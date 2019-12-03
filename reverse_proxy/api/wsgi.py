import os
from api import create_app

env = os.environ.get('FLASK_ENV', 'production')
app = create_app(f'config.{env.capitalize()}Config')
