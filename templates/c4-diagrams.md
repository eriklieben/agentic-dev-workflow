# C4 Diagrams: [System Name]

> **Date:** [YYYY-MM-DD]
> **Author:** [Name]
> **System:** [System being documented]

## Level 1: System Context

Who uses the system and what other systems does it interact with?

```mermaid
C4Context
    title System Context Diagram — [System Name]

    Person(user, "User", "Description of the user")

    System(system, "System Name", "What the system does")

    System_Ext(ext1, "External System 1", "What it does")
    System_Ext(ext2, "External System 2", "What it does")

    Rel(user, system, "Uses", "HTTPS")
    Rel(system, ext1, "Sends data to", "REST/JSON")
    Rel(system, ext2, "Reads from", "gRPC")
```

## Level 2: Container

What are the high-level technical building blocks?

```mermaid
C4Container
    title Container Diagram — [System Name]

    Person(user, "User", "Description")

    System_Boundary(boundary, "System Name") {
        Container(web, "Web App", "Angular", "Delivers the SPA")
        Container(api, "API", "ASP.NET Core", "Handles business logic")
        ContainerDb(db, "Database", "PostgreSQL", "Stores domain data")
        ContainerQueue(queue, "Message Bus", "RabbitMQ", "Async messaging")
    }

    System_Ext(ext, "External System", "Description")

    Rel(user, web, "Uses", "HTTPS")
    Rel(web, api, "Calls", "REST/JSON")
    Rel(api, db, "Reads/Writes", "TCP")
    Rel(api, queue, "Publishes", "AMQP")
    Rel(api, ext, "Integrates", "REST")
```

## Level 3: Component

What are the key components inside a container?

```mermaid
C4Component
    title Component Diagram — [Container Name]

    Container_Boundary(api, "API") {
        Component(controllers, "Endpoints", "ASP.NET Minimal API", "HTTP request handling")
        Component(services, "Domain Services", "C#", "Business logic")
        Component(repos, "Repositories", "C#", "Data access")
        Component(events, "Event Handlers", "C#", "Process domain events")
    }

    ContainerDb(db, "Database", "PostgreSQL", "Domain data")
    ContainerQueue(queue, "Message Bus", "RabbitMQ", "Events")

    Rel(controllers, services, "Uses")
    Rel(services, repos, "Uses")
    Rel(services, events, "Publishes")
    Rel(repos, db, "Reads/Writes")
    Rel(events, queue, "Sends to")
```

## Level 4: Code (optional)

Key class relationships within a component. Use standard class diagrams.

```mermaid
classDiagram
    class Aggregate {
        +Id: StronglyTypedId
        +Version: int
        +Apply(event) void
        -When(event) void
    }
    class Repository {
        +GetAsync(id) Aggregate
        +SaveAsync(aggregate) void
    }
    class EventStream {
        +Append(event) void
        +ReadAsync(id) Event[]
    }

    Repository --> Aggregate : loads/saves
    Repository --> EventStream : reads/writes
    Aggregate --> Event : produces
```

## Deployment (optional)

```mermaid
C4Deployment
    title Deployment Diagram — [Environment]

    Deployment_Node(cloud, "Cloud Provider", "Azure / AWS / GCP") {
        Deployment_Node(region, "Region", "e.g., West Europe") {
            Deployment_Node(aca, "Container Apps", "Serverless containers") {
                Container(api, "API", "ASP.NET Core", "Business logic")
            }
            Deployment_Node(swa, "Static Web Apps", "CDN + serverless") {
                Container(web, "Web App", "Angular", "SPA")
            }
            Deployment_Node(data, "Data Services") {
                ContainerDb(db, "Database", "PostgreSQL")
                ContainerDb(storage, "Blob Storage", "Azure Storage")
            }
        }
    }

    Rel(web, api, "Calls", "HTTPS")
    Rel(api, db, "Reads/Writes", "TCP")
    Rel(api, storage, "Stores files", "HTTPS")
```

## Notes

- Diagrams should be updated when architecture changes
- Level 4 (Code) diagrams are optional — only create for complex components
- Use consistent color coding: internal = blue, external = grey, database = green
