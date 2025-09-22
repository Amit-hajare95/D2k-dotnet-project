FROM mcr.microsoft.com/dotnet/sdk:2.1 AS build
WORKDIR /app

COPY *.sln .
COPY hello-world-api/*.csproj ./hello-world-api/
RUN dotnet restore

COPY . .
WORKDIR /app/hello-world-api
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:2.1
WORKDIR /app
COPY --from=build /app/hello-world-api/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
