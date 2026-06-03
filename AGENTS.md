# Backend Template Architecture

This is an ASP.NET Core 8.0 GraphQL backend template using HotChocolate, Entity Framework Core, and PostgreSQL.

---

## Architecture Flow

The application follows a layered architecture with dependency injection:

```
GraphQL Query/Mutation
    ↓
Service (optional - for complex business logic)
    ↓
Repository (data access)
    ↓
DatabaseContext (EF Core)
    ↓
Database (PostgreSQL)
```

**Key Points:**

- GraphQL resolvers can call **Services** directly (for complex logic) or **Repositories** directly (for simple CRUD)
- Services are **optional** - only use them when you have business logic beyond basic CRUD
- Repositories handle all database operations and return `IQueryable` for GraphQL projection
- All dependencies are injected via constructor or method parameters

---

## Folder Structure

### `/Database`

Contains the EF Core DbContext and entity models.

- **AppDbContext.cs** - Database context with DbSets and entity configuration
- **Models/** - Entity classes that map to database tables

### `/Repositories`

Data access layer that handles database operations.

- One repository per entity
- Methods return `IQueryable<T>` for GraphQL queries or `Task<T>` for mutations
- Injected with `DatabaseContext`

### `/Services`

Business logic layer (optional).

- Use when you need validation, complex processing, or orchestration of multiple repositories
- Keep repositories simple and put complex logic here
- Injected with repositories

### `/Queries`

GraphQL query resolvers.

- Use `[ExtendObjectType(typeof(BackendQueries))]` to extend the schema
- Methods become GraphQL query fields
- Inject `UserContext`, services, or repositories as parameters
- Use `[UsePaging]`, `[UseProjection]`, `[UseFiltering]`, `[UseSorting]` attributes as needed

### `/Mutations`

GraphQL mutation resolvers.

- Use `[ExtendObjectType(typeof(BackendMutations))]` to extend the schema
- Methods become GraphQL mutation fields
- Inject `UserContext`, services, or repositories as parameters
- Use input types from the Types folder for parameters

### `/Types`

GraphQL input/output types and DTOs.

- **Input types** - Use `record` types for mutation inputs (e.g., `CreateUserInput`)
- **Payload types** - Use `record` types for mutation responses (e.g., `UserPayload`)
- **Enums** - Define enum types for fixed value sets

### `/Middleware`

HTTP middleware components.

- **UserContextMiddleware.cs** - Sample middleware showing how to extract user context from headers
- Add custom middleware here for authentication, logging, etc.

### `/Extension`

Extension methods for service registration.

- **ServiceCollectionExtensions.cs** - Register repositories and services
- **GraphQLExtensions.cs** - Register GraphQL query and mutation type extensions

---

## Getting Started

1. **Configure database** in `appsettings.json`:

   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Host=localhost;Database=mydb;Username=postgres;Password=yourpassword"
     }
   }
   ```

2. **Add your models** to `Database/Models/`

3. **Configure entities** in `AppDbContext.cs` and add DbSets

4. **Create and run migrations**:

   ```bash
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

5. **Create repositories** in `Repositories/` and register in `ServiceCollectionExtensions.cs`

6. **Create queries/mutations** in `Queries/` or `Mutations/` and register in `GraphQLExtensions.cs`

7. **Run the application**:

   ```bash
   dotnet run
   ```

8. **Access GraphQL Playground**: `https://localhost:5001/graphql/`

---

## Example Pattern

### Simple CRUD (Query → Repository → Database)

```csharp
// Query
[ExtendObjectType(typeof(BackendQueries))]
public class ProductQueries
{
    public IQueryable<Product> GetProducts(ProductRepository repo)
        => repo.GetAll();
}

// Repository
public class ProductRepository
{
    private readonly DatabaseContext _db;

    public IQueryable<Product> GetAll()
        => _db.Products.OrderByDescending(p => p.CreatedAt);
}
```

### Complex Logic (Mutation → Service → Repository → Database)

```csharp
// Mutation
[ExtendObjectType(typeof(BackendMutations))]
public class ProductMutations
{
    public async Task<ProductPayload> CreateProduct(
        UserContext userContext,
        ProductService service,
        CreateProductInput input)
        => await service.CreateProductWithValidation(userContext.UserId, input);
}

// Service
public class ProductService
{
    private readonly ProductRepository _repo;

    public async Task<ProductPayload> CreateProductWithValidation(int userId, CreateProductInput input)
    {
        // Validation logic
        // Business logic
        var product = await _repo.CreateAsync(userId, input);
        return new ProductPayload(product.Id, product.Name);
    }
}

// Repository
public class ProductRepository
{
    private readonly DatabaseContext _db;

    public async Task<Product> CreateAsync(int userId, CreateProductInput input)
    {
        // Database operations
    }
}
```
