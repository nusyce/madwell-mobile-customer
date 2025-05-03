# Environment Configuration Examples

This directory contains example `.env` files for different environments:

- `env.dev`: Example environment variables for the development environment
- `env.staging`: Example environment variables for the staging environment
- `env.prod`: Example environment variables for the production environment

## Usage

Copy these files to the project root and rename them:

```bash
# For development
cp .env_examples/env.dev .env.dev

# For staging
cp .env_examples/env.staging .env.staging

# For production
cp .env_examples/env.prod .env.prod
```

## Important Security Note

These examples contain API keys and other sensitive values that should be kept private in a real project. In a production environment:

1. Never commit actual `.env` files to version control
2. Use different API keys and Firebase projects for each environment
3. Properly secure all API keys and credentials
4. Consider using a secrets management service for sensitive values 