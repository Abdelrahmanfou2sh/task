# lib Directory Structure

This project uses a feature-based structure inspired by Clean Architecture principles.

- `core/`: Shared code (dependency injection, base models, utilities, services)
- `features/`: Each feature (auth, home, agent, customer, admin) is self-contained with its own data, domain, and presentation layers
- `app/`: App-wide configuration (router, theme, etc.)
- `main.dart`: Entry point

## Example Feature Structure
```
features/
  auth/
    data/
      datasources/
      models/
      repositories/
    domain/
      entities/
      repositories/
      usecases/
    presentation/
      cubit/
      pages/
      widgets/
```

This structure promotes scalability, testability, and separation of concerns. 