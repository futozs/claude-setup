---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
---
# Python

- Use the project's environment tool (`uv` if `uv.lock`, poetry if `poetry.lock`, else the existing venv). Prefer `uv` for new projects. Never `pip install` into the system Python.
- Type hints on public functions; `ruff` for lint+format and `pyright`/`mypy` if configured.
- `pathlib` over `os.path`, f-strings, dataclasses/pydantic for structured data, context managers for resources.
- Catch specific exceptions only where you can handle them; let the rest propagate.
- Tests with pytest; fixtures over setup boilerplate.
- Django/FastAPI: follow the project's existing app/router layout; parameterized queries / ORM only; migrations for every model change.
