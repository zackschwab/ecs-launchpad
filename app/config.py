from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    
    # Default app settings will be used if pydantic doesn't find these variables
    app_version: str = "0.1.0"
    environment: str = "development"

    class Config:
        # If present, loads variables from .env file
        # In ECS, the task definition will inject environment variables
        env_file = ".env"


settings = Settings()
