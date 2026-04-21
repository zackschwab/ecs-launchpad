from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    
    # Injected at deploy time by the CD pipeline via the git tag or commit SHA
    app_version: str = "unknown"
    environment: str = "development"

    class Config:
        # If present, loads variables from .env file
        # In ECS, the task definition will inject environment variables
        env_file = ".env"


settings = Settings()
