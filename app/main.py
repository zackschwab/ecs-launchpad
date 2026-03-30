from fastapi import FastAPI
from app.config import settings

app = FastAPI(
    title="ECS Launchpad",
    version=settings.app_version,
)

@app.get("/")
def root():
    return {
        "app": "ecs-launchpad",
        "version": settings.app_version,
        "environment": settings.environment,
    }

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": settings.app_version,
        "environment": settings.environment,
    }
