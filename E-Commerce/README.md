Django E-Commerce starter project

How to run:

1. Create a virtual environment and install requirements:

   python -m venv .venv; .\.venv\Scripts\Activate.ps1; pip install -r requirements.txt

2. Apply migrations and runserver:

   python manage.py migrate
   python manage.py runserver

Pages:
- /register
- /login
- /dashboard (requires login)
